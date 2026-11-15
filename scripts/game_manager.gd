# ORIGIN: Brackeys tutorial (human-written): score + add_point().
# MODIFIED BY TEAM (AI-assisted): Hollow Knight-style systems:
#   MASKS (health), GEO (coins), BENCHES (checkpoint + heal), hazard respawn,
#   enemy HP, and THE TWIST: when you die, your body stays as a BOUNCE PAD holding your geo.
#   Hit your body with the nail (or pogo it) to get your geo back. Bounce back!
extends Node

const BodyPad = preload("res://scripts/body_pad.gd")
const FONT = preload("res://assets/fonts/PixelOperator8-Bold.ttf")
const MAX_BODIES := 25
const MAX_MASKS := 5
const ENEMY_HP := 2

var score = 0                 # = GEO (Brackeys coins)
var deaths := 0
var masks := MAX_MASKS
var respawn_point := Vector2.ZERO
var dead := false
var player: CharacterBody2D
var bodies: Array = []
var hud: Control
var geo_label: Label
var death_label: Label

@onready var score_label = $ScoreLabel


func _ready():
	add_to_group("game_manager")
	_build_hud()
	await get_tree().process_frame          # wait for the whole level to load
	player = get_tree().get_first_node_in_group("player")
	if player:
		respawn_point = player.global_position


func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins."
	_update_hud()


# BENCH: respawn here + full heal
func set_checkpoint(pos: Vector2) -> void:
	respawn_point = pos
	masks = MAX_MASKS
	_update_hud()
	_toast("BENCH: RESTED")


# ---------------- DAMAGE ----------------
func player_hit(from_pos: Vector2, hazard := false) -> void:
	if dead or player == null or player.invuln > 0.0:
		return
	masks -= 1
	_update_hud()
	_shake(4.0)
	if masks <= 0:
		player_died(true)
		return
	player.take_hit(from_pos)
	if hazard:
		# Hollow Knight hazard respawn: back to the last safe ground
		player.controllable = false
		await get_tree().create_timer(0.35).timeout
		if not dead:
			player.respawn(player.last_safe)


func player_died(leave_body := true) -> void:
	if dead or player == null:
		return
	dead = true
	deaths += 1
	var where := player.global_position
	if player.global_position.y > player.last_safe.y + 60.0:
		where = player.last_safe      # died falling into a pit: body appears at the edge
	var facing_left: bool = player.animated_sprite.flip_h
	var dropped: int = score
	score = 0
	player.die()
	_update_hud()
	_shake(8.0)
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.3).timeout   # 0.6 s of slow-mo
	Engine.time_scale = 1.0
	if leave_body:
		_spawn_body(where, facing_left, dropped)
	masks = MAX_MASKS
	player.respawn(respawn_point)
	_update_hud()
	dead = false


func _spawn_body(pos: Vector2, facing_left: bool, geo: int) -> void:
	var b = BodyPad.new()
	b.frames = player.animated_sprite.sprite_frames
	b.flip = facing_left
	b.geo = geo
	b.global_position = pos
	get_tree().current_scene.add_child(b)
	bodies.append(b)
	if bodies.size() > MAX_BODIES:
		bodies.pop_front().queue_free()


# Hit your old body with the nail = take your geo back
func reclaim_geo(body) -> void:
	if body.geo <= 0:
		return
	score += body.geo
	_toast("+%d GEO RECLAIMED" % body.geo)
	body.geo = 0
	body.set_reclaimed()
	_update_hud()


# ---------------- ENEMIES ----------------
func hit_enemy(enemy: Node, by: Node2D) -> void:
	if not is_instance_valid(enemy) or enemy.has_meta("dying"):
		return
	var hp: int = enemy.get_meta("hp", ENEMY_HP) - 1
	enemy.set_meta("hp", hp)
	var tw := enemy.create_tween()
	enemy.modulate = Color(3, 3, 3)
	tw.tween_property(enemy, "modulate", Color.WHITE, 0.15)
	if enemy is Node2D:
		enemy.position.x += 6.0 * signf(enemy.global_position.x - by.global_position.x)
	if hp <= 0:
		enemy.set_meta("dying", true)
		score += 2                                   # enemies drop geo
		_update_hud()
		_shake(3.0)
		var t2 := enemy.create_tween()
		t2.tween_property(enemy, "scale", Vector2(1.4, 0.2), 0.15)
		t2.tween_callback(enemy.queue_free)


# ---------------- HUD (masks + geo + deaths) ----------------
func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Control.new()
	hud.position = Vector2(12, 10)
	hud.draw.connect(_draw_masks)
	layer.add_child(hud)
	geo_label = _make_label(16, Vector2(12, 34))
	layer.add_child(geo_label)
	death_label = _make_label(16, Vector2(12, 56))
	layer.add_child(death_label)
	_update_hud()


func _make_label(size: int, pos: Vector2) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	l.position = pos
	return l


func _draw_masks() -> void:
	for i in MAX_MASKS:
		var c := Vector2(10 + i * 22, 10)
		var full := i < masks
		hud.draw_circle(c, 9.0, Color.BLACK)
		hud.draw_circle(c, 7.0, Color(0.95, 0.95, 1.0) if full else Color(0.25, 0.25, 0.3))
		if full:
			hud.draw_circle(c + Vector2(-3, -1), 1.6, Color.BLACK)
			hud.draw_circle(c + Vector2(3, -1), 1.6, Color.BLACK)


func _update_hud() -> void:
	if hud:
		hud.queue_redraw()
	if geo_label:
		geo_label.text = "GEO %d" % score
	if death_label:
		death_label.text = "Deaths: %d" % deaths if deaths > 0 else ""


func _shake(amount: float) -> void:
	if player == null:
		return
	var cam: Camera2D = player.get_node_or_null("Camera2D")
	if cam == null:
		return
	var tw := cam.create_tween()
	for i in 4:
		tw.tween_property(cam, "offset", Vector2(randf_range(-amount, amount), randf_range(-amount, amount)), 0.03)
	tw.tween_property(cam, "offset", Vector2.ZERO, 0.03)


func _toast(text: String) -> void:
	if player == null:
		return
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 4)
	get_tree().current_scene.add_child(l)
	l.global_position = player.global_position + Vector2(-40, -40)
	var tw := l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 20, 0.9)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.9)
	tw.tween_callback(l.queue_free)
