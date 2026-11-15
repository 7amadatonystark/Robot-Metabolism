# GAME MANAGER: spawning, collisions, score, UI, sound, screen shake.
extends Node2D

# ===================== THEME KNOBS: change these to fit the jam theme =====================
const GAME_TITLE := "BOUNCEBACK BOT"
const TAGLINE := "Get scrapped. Bounce back bigger."
const BG_COLOR := Color("14161f")
const GRID_COLOR := Color(1, 1, 1, 0.045)
const PLAYER_CORE := Color("eceff1")
const ENEMY_CORE := Color("8d99ae")
var ARENA_HALF := 1600.0
# ===========================================================================================

const DB = preload("res://scripts/parts_db.gd")
const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const ScrapScript = preload("res://scripts/scrap.gd")
const BulletScript = preload("res://scripts/bullet.gd")
const FloatTextScript = preload("res://scripts/float_text.gd")
const Mut = preload("res://scripts/mutations.gd")

enum State { TITLE, PLAY, CHOOSE, DEAD }
var state := State.TITLE

var world: Node2D
var cam: Camera2D
var player
var enemies: Array = []
var scraps: Array = []
var bullets: Array = []

var shake := 0.0
var elapsed := 0.0
var eaten := 0
var best_mass := 1
var highscore := 0
var dead_time := 0.0
var combo := 0
var combo_t := 0.0
var scrap_t := 0.0
var score := 0
var frenzy := 0            # robots eaten in a quick chain -> score multiplier
var frenzy_t := 0.0
var milestone_i := 0
var megabot_time := -1.0   # seconds it took to reach MEGABOT, -1 = not yet
var card_box: HBoxContainer
var card_choices: Array = []
# ---- BOUNCE BACK (jam theme) ----
var bounce_backs := 0
var lost_pending := 0      # parts knocked off in the last hit
var recovered := 0         # how many of them you grabbed back
var recover_t := 0.0       # time left to grab them back
var reboot_t := 0.0        # > 0 = you're a bare core, grab 3 parts or die
var reboot_got := 0
const RECOVER_TIME := 3.0
const REBOOT_TIME := 5.0
const REBOOT_NEED := 3
var autopilot := false     # run with: godot -- --bot   (used for testing)

var ui_stats: Label
var ui_title: Label
var ui_body: Label

var sfx := {}
var sfx_players: Array = []
var sfx_idx := 0
var music: AudioStreamPlayer


func _ready() -> void:
	randomize()
	RenderingServer.set_default_clear_color(BG_COLOR)
	autopilot = "--bot" in OS.get_cmdline_user_args()
	world = Node2D.new()
	add_child(world)
	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()
	_build_ui()
	_load_audio()
	_load_highscore()
	_reset_world()
	_show_title()
	if autopilot:
		_start()


func is_playing() -> bool:
	return state == State.PLAY

func is_attract() -> bool:
	return state == State.TITLE


# ------------------------------------------------------------------ game flow
func _reset_world() -> void:
	for c in world.get_children():
		c.queue_free()
	enemies.clear()
	scraps.clear()
	bullets.clear()
	elapsed = 0.0
	eaten = 0
	best_mass = 1
	score = 0
	frenzy = 0
	milestone_i = 0
	megabot_time = -1.0
	bounce_backs = 0
	lost_pending = 0
	recover_t = 0.0
	reboot_t = 0.0
	player = PlayerScript.new()
	player.game = self
	player.core_color = PLAYER_CORE
	world.add_child(player)
	cam.position = Vector2.ZERO
	for i in 60:
		_spawn_scrap(_random_arena_pos(), randi() % DB.COUNT, Vector2.ZERO, 0.0)
	for i in 8:
		var m := randi_range(1, 3) if i < 6 else randi_range(7, 10)
		_spawn_enemy(Vector2.from_angle(randf() * TAU) * randf_range(400.0, 1100.0), m)


func _start() -> void:
	state = State.PLAY
	ui_title.text = ""
	ui_body.text = ""
	card_box.visible = false
	play_sfx("start")


func _show_title() -> void:
	state = State.TITLE
	ui_title.text = GAME_TITLE
	ui_body.text = TAGLINE + "\n\nWASD / Arrows / hold Mouse to move\nTouch loose parts to bolt them on     SPACE / Right-click = DASH\nGet hit? Your parts scatter. Grab them back fast = BOUNCE BACK!\nGREEN ring = eat it     RED ring = run!\n\nWHEEL +speed   CLAW +bite   MAGNET +pull   CANNON +gun\nGrow to pick MUTATIONS. Reach size %d to become MEGABOT!\n\nPress ENTER or click to start" % Mut.MEGABOT_SIZE


func _game_over() -> void:
	state = State.DEAD
	dead_time = 0.0
	score += best_mass * 10
	var new_best := score > highscore
	if new_best:
		highscore = score
		_save_highscore()
	burst(player.position, PLAYER_CORE, 40, 500.0)
	player.visible = false
	shake = 25.0
	play_sfx("explode", 3.0, 0.7)
	ui_title.text = "SCRAPPED!"
	var mega := ("MEGABOT reached in %ds!\n" % int(megabot_time)) if megabot_time >= 0.0 else ""
	ui_body.text = "Score: %d%s\n%sBiggest size: %d   Robots eaten: %d   Bounce-backs: %d   Survived: %ds\nBest: %d\n\nPress ENTER or click to bounce back" % [
		score, "   NEW BEST!" if new_best else "", mega, best_mass, eaten, bounce_backs, int(elapsed), highscore]


func _unhandled_input(event: InputEvent) -> void:
	if state == State.CHOOSE:
		if event is InputEventKey and event.pressed and not event.echo:
			var n: int = event.keycode - KEY_1
			if n >= 0 and n < card_choices.size():
				_pick_mutation(n)
		return
	var go := false
	if event is InputEventKey and event.pressed and not event.echo:
		go = event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_R]
	elif event is InputEventMouseButton and event.pressed:
		go = true
	if not go:
		return
	if state == State.TITLE:
		_start()
	elif state == State.DEAD and dead_time > 0.8:
		_reset_world()
		_start()


# ------------------------------------------------------------------ main loop
func _process(delta: float) -> void:
	if state == State.PLAY:
		elapsed += delta
		combo_t -= delta
		if combo_t <= 0.0:
			combo = 0
		frenzy_t -= delta
		if frenzy_t <= 0.0:
			frenzy = 0
		recover_t = maxf(recover_t - delta, 0.0)
		if reboot_t > 0.0:
			reboot_t -= delta
			if reboot_t <= 0.0:
				reboot_t = 0.0
				_game_over()
		if state == State.PLAY:
			_collisions()
		if state == State.PLAY:
			_spawning()
			best_mass = maxi(best_mass, player.mass())
			_check_milestones()
	elif state == State.CHOOSE:
		if autopilot:
			_pick_mutation(0)
	elif state == State.DEAD:
		dead_time += delta
		if autopilot and dead_time > 1.0:
			print("BOT DIED t=%d best=%d eaten=%d" % [elapsed, best_mass, eaten])
			_reset_world()
			_start()
	if autopilot and Engine.get_process_frames() % 300 == 0:
		print("bb=%d reboot=%.1f frame %d state=%d score=%d muts=%s size=%d eaten=%d enemies=%d scrap=%d bullets=%d" % [bounce_backs, reboot_t, Engine.get_process_frames(), state, score, str(player.mut.keys()), player.mass(), eaten, enemies.size(), scraps.size(), bullets.size()])

	# camera follows the player and zooms out as you grow
	cam.position = cam.position.lerp(player.position, 1.0 - exp(-6.0 * delta))
	var z := clampf(1.25 - (player.radius() - 21.0) / 200.0, 0.4, 1.25)
	cam.zoom = cam.zoom.lerp(Vector2(z, z), 1.0 - exp(-2.0 * delta))
	shake = maxf(shake - delta * 40.0, 0.0)
	cam.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake
	_update_ui()


func _collisions() -> void:
	var pp: Vector2 = player.position
	var pr: float = player.radius()

	# scrap: player picks up, enemies eat it too
	for i in range(scraps.size() - 1, -1, -1):
		var s = scraps[i]
		if s.pickup_delay > 0.0:
			continue
		if s.position.distance_to(pp) < pr + 8.0:
			_collect(s)
			scraps.remove_at(i)
			continue
		for e in enemies:
			if e.mass() < 45 and s.position.distance_to(e.position) < e.radius() + 6.0:
				e.parts.append(s.kind)
				e.hp += 8.0
				s.queue_free()
				scraps.remove_at(i)
				break

	# enemies: eat them or get hurt
	for i in range(enemies.size() - 1, -1, -1):
		var e = enemies[i]
		if e.position.distance_to(pp) < pr + e.radius() * 0.8:
			if player.power() > e.mass():
				_eat_enemy(e)
				enemies.remove_at(i)
			elif player.invuln <= 0.0:
				_hurt_player(e.mass(), (pp - e.position).normalized(), e)
				if state != State.PLAY:
					return

	# bullets
	for i in range(bullets.size() - 1, -1, -1):
		var b = bullets[i]
		if b.life <= 0.0:
			b.queue_free()
			bullets.remove_at(i)
			continue
		if b.friendly:
			for j in range(enemies.size() - 1, -1, -1):
				var e = enemies[j]
				if b.position.distance_to(e.position) < e.radius():
					e.hp -= b.dmg
					e.flash = 1.0
					if e.hp <= 0.0:
						_destroy_enemy(e)
						enemies.remove_at(j)
					b.queue_free()
					bullets.remove_at(i)
					break
		elif b.position.distance_to(pp) < pr:
			b.queue_free()
			bullets.remove_at(i)
			if player.invuln <= 0.0:
				_hurt_player(2, b.vel.normalized())
				if state != State.PLAY:
					return


func _collect(s) -> void:
	player.parts.append(s.kind)
	combo += 1
	combo_t = 1.2
	score += 1 + frenzy
	# REBOOT: bare core grabbing parts to come back to life
	if reboot_t > 0.0:
		reboot_got += 1
		if reboot_got >= REBOOT_NEED:
			reboot_t = 0.0
			bounce_backs += 1
			score += 300
			player.invuln = 2.0
			player.boost_t = 3.0
			float_text(player.position + Vector2(0, -60), "REBOOTED! BOUNCE BACK!", Color("00e5ff"), 44)
			burst(player.position, Color("00e5ff"), 50, 600.0)
			play_sfx("start", 2.0, 1.2)
			shake = 18.0
			hitstop(0.12)
	# Grabbed back a part that was knocked off you
	elif s.lost and recover_t > 0.0 and lost_pending > 0:
		recovered += 1
		if recovered >= lost_pending:
			bounce_backs += 1
			score += 100 * lost_pending
			player.boost_t = 2.5
			float_text(player.position + Vector2(0, -50), "FULL BOUNCE BACK! +%d" % (100 * lost_pending), Color("ffd54f"), 38)
			burst(player.position, Color("ffd54f"), 40, 500.0)
			play_sfx("boing", 2.0, 1.3)
			shake = 10.0
			lost_pending = 0
			recover_t = 0.0
	play_sfx("pickup", -4.0, 1.0 + minf(combo, 12) * 0.06)
	float_text(s.position, DB.PERKS[s.kind], DB.COLORS[s.kind])
	burst(s.position, DB.COLORS[s.kind], 8, 160.0)
	s.queue_free()


func _eat_enemy(e) -> void:
	# You absorb 30% of its parts (plus one), so growth stays fun, not instant
	var ratio := 0.6 if player.mut.has("APPETITE") else 0.3
	var gained: int = int(ceil(e.parts.size() * ratio)) + 1
	e.parts.shuffle()
	for k in gained - 1:
		player.parts.append(e.parts[k])
	player.parts.append(randi() % DB.COUNT)
	eaten += 1
	frenzy += 1
	frenzy_t = 3.0
	score += 25 * frenzy
	if frenzy >= 2:
		float_text(e.position + Vector2(0, -40), "FRENZY x%d" % frenzy, Color("ffd54f"), 26 + mini(frenzy, 8) * 3)
	player.flash = 0.6
	shake = 9.0 + minf(gained, 15)
	burst(e.position, ENEMY_CORE, 24, 380.0)
	play_sfx("eat", 0.0, 1.0)
	float_text(e.position, "CHOMP! +%d" % gained, Color("69f0ae"), 30)
	hitstop(0.05)
	e.queue_free()


func _destroy_enemy(e) -> void:
	var n := mini(e.parts.size(), 12)
	for k in n:
		_spawn_scrap(e.position, e.parts[k], Vector2.from_angle(randf() * TAU) * randf_range(150.0, 350.0), 0.3)
	burst(e.position, Color("ffb74d"), 30, 420.0)
	play_sfx("explode", -2.0)
	shake = maxf(shake, 6.0)
	e.queue_free()


func _hurt_player(enemy_mass: int, push: Vector2, attacker = null) -> void:
	if player.parts.is_empty():
		if reboot_t > 0.0:
			_game_over()       # hit again while rebooting = scrapped
			return
		# Last chance: bare core, grab 3 parts in 5 s to bounce back
		reboot_t = REBOOT_TIME
		reboot_got = 0
		lost_pending = 0
		player.invuln = 1.2
		player.vel = push * 700.0
		shake = 20.0
		play_sfx("hurt", 2.0, 0.6)
		float_text(player.position + Vector2(0, -50), "CORE EXPOSED!", Color("ff5252"), 40)
		hitstop(0.15)
		return
	# SPIKED HULL: the attacker loses parts too (and might become edible!)
	if attacker and player.mut.has("SPIKES"):
		for k in mini(3, attacker.parts.size()):
			var ak: int = attacker.parts.pop_back()
			_spawn_scrap(attacker.position, ak, Vector2.from_angle(randf() * TAU) * 300.0, 0.3)
		attacker.flash = 1.0
		attacker.vel = -push * 700.0
	var lose := mini(clampi(int(ceil(enemy_mass * 0.25)), 1, 8), player.parts.size())
	if player.mut.has("ARMOR"):
		lose = maxi(1, lose / 2)
	for k in lose:
		var idx: int = randi() % player.parts.size()
		var kind: int = player.parts[idx]
		player.parts.remove_at(idx)
		_spawn_scrap(player.position, kind, Vector2.from_angle(randf() * TAU) * randf_range(250.0, 450.0), 0.6)
		scraps[-1].lost = true
	lost_pending = lose
	recovered = 0
	recover_t = RECOVER_TIME
	player.invuln = 1.0
	player.flash = 1.0
	player.vel = push * 650.0
	shake = 16.0
	play_sfx("hurt")
	float_text(player.position, "-%d PARTS" % lose, Color("ff5252"), 28)
	hitstop(0.08)


func _spawning() -> void:
	var target_enemies := mini(7 + int(elapsed / 15.0), 22)
	if enemies.size() < target_enemies:
		var pm: int = player.mass()
		var m: int
		if randf() < 0.6:
			m = int(pm * randf_range(0.3, 0.9))
		else:
			m = int(pm * randf_range(1.2, 2.2)) + 3
		var pos: Vector2 = player.position + Vector2.from_angle(randf() * TAU) * randf_range(750.0, 1150.0)
		_spawn_enemy(pos.clamp(Vector2.ONE * -ARENA_HALF, Vector2.ONE * ARENA_HALF), clampi(m, 1, 80))
	scrap_t -= get_process_delta_time()
	if scraps.size() < 50 and scrap_t <= 0.0:
		scrap_t = 0.35
		_spawn_scrap(_random_arena_pos(), randi() % DB.COUNT, Vector2.ZERO, 0.0)


# ------------------------------------------------------------------ spawners & helpers
func _random_arena_pos() -> Vector2:
	return Vector2(randf_range(-ARENA_HALF, ARENA_HALF), randf_range(-ARENA_HALF, ARENA_HALF))


func _spawn_enemy(pos: Vector2, m: int) -> void:
	var e = EnemyScript.new()
	e.game = self
	e.core_color = ENEMY_CORE
	e.position = pos
	e.setup(m)
	world.add_child(e)
	enemies.append(e)


func _spawn_scrap(pos: Vector2, kind: int, vel: Vector2, delay: float) -> void:
	var s = ScrapScript.new()
	s.game = self
	s.kind = kind
	s.position = pos
	s.vel = vel
	s.pickup_delay = delay
	world.add_child(s)
	scraps.append(s)


func spawn_bullet(pos: Vector2, dir: Vector2, friendly: bool, dmg: float) -> void:
	var b = BulletScript.new()
	b.position = pos
	b.vel = dir * (700.0 if friendly else 380.0)
	b.friendly = friendly
	b.dmg = dmg
	world.add_child(b)
	bullets.append(b)
	if friendly:
		play_sfx("shoot", -12.0)


func nearest_enemy(pos: Vector2, max_dist: float):
	var best = null
	var best_d := max_dist
	for e in enemies:
		var d := pos.distance_to(e.position)
		if d < best_d:
			best_d = d
			best = e
	return best


# Simple bot used for automatic testing: grab scrap, eat small bots, avoid big ones.
func autopilot_dir() -> Vector2:
	var pp: Vector2 = player.position
	var dir := Vector2.ZERO
	for e in enemies:
		var d: float = pp.distance_to(e.position)
		if d < 300.0 and player.power() <= e.mass() and not ("--reckless" in OS.get_cmdline_user_args()):
			dir += (pp - e.position).normalized() * 3.0
	var goal = null
	var gd := 1e9
	for s in scraps:
		var d: float = pp.distance_to(s.position)
		if d < gd:
			gd = d
			goal = s
	for e in enemies:
		if player.power() > e.mass() and pp.distance_to(e.position) < gd:
			gd = pp.distance_to(e.position)
			goal = e
	if goal:
		dir += (goal.position - pp).normalized()
	return dir


# ------------------------------------------------------------------ mutations & dash
func _check_milestones() -> void:
	if megabot_time < 0.0 and player.mass() >= Mut.MEGABOT_SIZE:
		megabot_time = elapsed
		float_text(player.position + Vector2(0, -player.radius()), "MEGABOT ONLINE!", Color("00e5ff"), 56)
		score += 2000
		shake = 30.0
		burst(player.position, Color("00e5ff"), 60, 700.0)
		play_sfx("start", 4.0, 0.6)
		hitstop(0.4)
	if milestone_i < Mut.MILESTONES.size() and player.mass() >= Mut.MILESTONES[milestone_i]:
		milestone_i += 1
		card_choices = Mut.pick_three(player.mut)
		if card_choices.is_empty():
			return
		state = State.CHOOSE
		play_sfx("start", 0.0, 1.3)
		ui_title.text = "METABOLISM SURGE!"
		ui_body.text = "Pick a mutation (click or press 1 / 2 / 3)"
		for c in card_box.get_children():
			c.queue_free()
		for i in card_choices.size():
			var m: Dictionary = card_choices[i]
			var b := Button.new()
			b.text = "[%d]\n%s\n\n%s" % [i + 1, m.name, m.desc]
			b.custom_minimum_size = Vector2(250, 170)
			b.add_theme_font_size_override("font_size", 22)
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color("1e2230")
			sb.border_color = Color(m.color)
			sb.set_border_width_all(4)
			sb.set_corner_radius_all(14)
			var sb_hover := sb.duplicate()
			sb_hover.bg_color = Color(Color(m.color), 0.35)
			b.add_theme_stylebox_override("normal", sb)
			b.add_theme_stylebox_override("hover", sb_hover)
			b.add_theme_stylebox_override("pressed", sb_hover)
			b.add_theme_stylebox_override("focus", sb_hover)
			b.add_theme_color_override("font_color", Color(m.color))
			b.add_theme_color_override("font_hover_color", Color.WHITE)
			b.pressed.connect(_pick_mutation.bind(i))
			card_box.add_child(b)
		card_box.visible = true


func _pick_mutation(i: int) -> void:
	if state != State.CHOOSE:
		return
	var m: Dictionary = card_choices[i]
	player.mut[m.id] = true
	card_box.visible = false
	ui_title.text = ""
	ui_body.text = ""
	state = State.PLAY
	player.invuln = 1.0
	play_sfx("eat", 0.0, 1.5)
	float_text(player.position + Vector2(0, -player.radius()), m.name + "!", Color(m.color), 40)
	burst(player.position, Color(m.color), 40, 500.0)
	shake = 12.0


func on_dash(pos: Vector2, _dir: Vector2) -> void:
	play_sfx("shoot", -2.0, 0.5)
	shake = maxf(shake, 4.0)
	burst(pos, Color("00e5ff"), 10, 200.0)


func on_wall_bounce(pos: Vector2, spd: float) -> void:
	if spd > 150.0:
		play_sfx("boing", -4.0, clampf(spd / 500.0, 0.7, 1.5))
		burst(pos, Color("00e5ff"), 8, 200.0)
		shake = maxf(shake, minf(spd / 100.0, 8.0))


func dash_trail(pos: Vector2) -> void:
	if Engine.get_process_frames() % 2 == 0:
		burst(pos, Color(0, 0.9, 1, 0.6), 3, 60.0)


# ------------------------------------------------------------------ juice
func burst(pos: Vector2, color: Color, amount: int = 16, spd: float = 250.0) -> void:
	var p := CPUParticles2D.new()
	p.position = pos
	p.one_shot = true
	p.amount = amount
	p.lifetime = 0.6
	p.explosiveness = 1.0
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = spd * 0.4
	p.initial_velocity_max = spd
	p.damping_min = spd * 0.8
	p.damping_max = spd * 1.2
	p.scale_amount_min = 3.0
	p.scale_amount_max = 7.0
	var g := Gradient.new()
	g.set_color(0, color)
	g.set_color(1, Color(color, 0.0))
	p.color_ramp = g
	world.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.2).timeout.connect(p.queue_free)


func float_text(pos: Vector2, text: String, color: Color, size: int = 22) -> void:
	var f = FloatTextScript.new()
	f.position = pos + Vector2(0, -20)
	f.text = text
	f.color = color
	f.size = size
	world.add_child(f)


func hitstop(dur: float) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(dur, true, false, true).timeout
	Engine.time_scale = 1.0


func play_sfx(sound_name: String, vol_db: float = 0.0, pitch: float = 1.0) -> void:
	if not sfx.has(sound_name):
		return
	var p: AudioStreamPlayer = sfx_players[sfx_idx]
	sfx_idx = (sfx_idx + 1) % sfx_players.size()
	p.stream = sfx[sound_name]
	p.volume_db = vol_db
	p.pitch_scale = pitch * randf_range(0.93, 1.07)
	p.play()


# ------------------------------------------------------------------ setup: audio, UI, save
func _load_audio() -> void:
	for n in ["eat", "pickup", "hurt", "shoot", "explode", "start", "boing"]:
		sfx[n] = load("res://sfx/%s.wav" % n)
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	music = AudioStreamPlayer.new()
	music.stream = load("res://sfx/music.wav")
	music.volume_db = -10.0
	add_child(music)
	music.finished.connect(music.play)
	music.play()


func _make_label(size: int) -> Label:
	var l := Label.new()
	var ls := LabelSettings.new()
	ls.font_size = size
	ls.outline_size = 8
	ls.outline_color = Color.BLACK
	l.label_settings = ls
	return l


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	ui_stats = _make_label(22)
	ui_stats.position = Vector2(18, 12)
	layer.add_child(ui_stats)
	var center := CenterContainer.new()
	layer.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	center.add_child(box)
	ui_title = _make_label(72)
	ui_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_title.label_settings.font_color = Color("00e5ff")
	box.add_child(ui_title)
	ui_body = _make_label(24)
	ui_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(ui_body)
	card_box = HBoxContainer.new()
	card_box.alignment = BoxContainer.ALIGNMENT_CENTER
	card_box.add_theme_constant_override("separation", 24)
	card_box.visible = false
	box.add_child(card_box)


func _update_ui() -> void:
	if state != State.PLAY and state != State.CHOOSE:
		ui_stats.text = "BEST %d" % highscore
		return
	var c := []
	for k in DB.COUNT:
		c.append("%s x%d" % [DB.NAMES[k], player.count(k)])
	var dash := "DASH READY" if player.dash_cd <= 0.0 else "DASH %.1f" % player.dash_cd
	var muts := []
	for id in player.mut:
		muts.append(id)
	var goal := "MEGABOT!" if megabot_time >= 0.0 else "%d / %d to MEGABOT" % [player.mass(), Mut.MEGABOT_SIZE]
	if state == State.PLAY:
		if reboot_t > 0.0:
			ui_title.text = "REBOOTING %.1f" % reboot_t
			ui_body.text = "Grab %d more parts to BOUNCE BACK!" % (REBOOT_NEED - reboot_got)
		elif ui_title.text.begins_with("REBOOTING"):
			ui_title.text = ""
			ui_body.text = ""
	var recover := ("   RECOVER YOUR PARTS! %d/%d (%.1fs)" % [recovered, lost_pending, recover_t]) if (recover_t > 0.0 and lost_pending > 0) else ""
	ui_stats.text = "SCORE %d   SIZE %d   POWER %d   EATEN %d   BOUNCE-BACKS %d   %s\n%s\n%s%s   %s" % [
		score, player.mass(), player.power(), eaten, bounce_backs, goal, "   ".join(c), dash, recover,
		("MUTATIONS: " + ", ".join(muts)) if muts.size() > 0 else ""]


func _draw() -> void:
	var a := ARENA_HALF
	var step := 80.0
	var x := -a
	while x <= a:
		draw_line(Vector2(x, -a), Vector2(x, a), GRID_COLOR, 2.0)
		draw_line(Vector2(-a, x), Vector2(a, x), GRID_COLOR, 2.0)
		x += step
	draw_rect(Rect2(-a, -a, a * 2.0, a * 2.0), Color("00e5ff"), false, 6.0)


func _load_highscore() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://save.cfg") == OK:
		highscore = cfg.get_value("game", "highscore", 0)


func _save_highscore() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "highscore", highscore)
	cfg.save("user://save.cfg")
