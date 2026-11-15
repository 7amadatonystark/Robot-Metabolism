# ORIGIN: Brackeys tutorial (human-written, public domain). Movement, gravity, jump, animations = Brackeys.
# MODIFIED BY TEAM (AI-assisted): Hollow Knight-style moves: nail attack (side/up/down),
# POGO (down-slash bounces you), dash, masks/knockback, hazard respawn, bouncing on old bodies.
extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const BOUNCE_VELOCITY = -420.0     # landing on one of your old bodies
const BOUNCE_BOOST = 1.2           # hold jump while bouncing = go even higher
const POGO_VELOCITY = -300.0       # down-slash hits something = bounce up (Hollow Knight pogo)
const DASH_SPEED = 330.0
const DASH_TIME = 0.16
const DASH_COOLDOWN = 0.45
const ATTACK_COOLDOWN = 0.32
const KNOCKBACK = Vector2(160, -170)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var controllable := true
var facing := 1
var invuln := 0.0
var attack_cd := 0.0
var dash_t := 0.0
var dash_cd := 0.0
var can_air_dash := true
var stun := 0.0                    # short loss of control after getting hit
var last_safe := Vector2.ZERO      # last solid ground (for hazard respawn)
var safe_t := 0.0
var slash_t := 0.0                 # slash effect timer
var slash_dir := Vector2.RIGHT

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
var sfx_jump: AudioStreamPlayer
var sfx_hurt: AudioStreamPlayer
var sfx_bounce: AudioStreamPlayer
var sfx_slash: AudioStreamPlayer


func _ready():
	add_to_group("player")
	_setup_inputs()
	last_safe = global_position
	sfx_jump = _make_sfx("res://assets/sounds/jump.wav")
	sfx_hurt = _make_sfx("res://assets/sounds/hurt.wav")
	sfx_bounce = _make_sfx("res://assets/sounds/power_up.wav")
	sfx_slash = _make_sfx("res://assets/sounds/tap.wav")


# Adds the extra controls (so nobody has to edit Project Settings)
func _setup_inputs() -> void:
	var keys := {
		"attack": [KEY_J, KEY_X],
		"dash": [KEY_K, KEY_C, KEY_SHIFT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
	}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for k in keys[action]:
				var ev := InputEventKey.new()
				ev.physical_keycode = k
				InputMap.action_add_event(action, ev)


func _make_sfx(path: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	add_child(p)
	return p


func _physics_process(delta):
	invuln = maxf(invuln - delta, 0.0)
	attack_cd = maxf(attack_cd - delta, 0.0)
	dash_cd = maxf(dash_cd - delta, 0.0)
	slash_t = maxf(slash_t - delta, 0.0)
	stun = maxf(stun - delta, 0.0)
	animated_sprite.modulate.a = 0.45 if (invuln > 0.0 and int(invuln * 20) % 2 == 0) else 1.0
	queue_redraw()
	if not controllable:
		return

	# DASH (Hollow Knight: Mothwing Cloak)
	if dash_t > 0.0:
		dash_t -= delta
		velocity = Vector2(facing * DASH_SPEED, 0)
		move_and_slide()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		can_air_dash = true
		_track_safe_ground(delta)

	if stun > 0.0:
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sfx_jump.pitch_scale = 1.0
		sfx_jump.play()
	# Variable jump height: let go of jump early = shorter jump (like Hollow Knight)
	if Input.is_action_just_released("jump") and velocity.y < -120.0:
		velocity.y = -120.0

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")

	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
		facing = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		facing = -1

	if Input.is_action_just_pressed("dash") and dash_cd <= 0.0 and (is_on_floor() or can_air_dash):
		dash_t = DASH_TIME
		dash_cd = DASH_COOLDOWN
		if not is_on_floor():
			can_air_dash = false
		sfx_jump.pitch_scale = 1.6
		sfx_jump.play()
		return

	if Input.is_action_just_pressed("attack") and attack_cd <= 0.0:
		_attack()

	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_check_bounce()


func _track_safe_ground(delta: float) -> void:
	safe_t -= delta
	if safe_t > 0.0:
		return
	safe_t = 0.2
	for i in get_slide_collision_count():
		var other = get_slide_collision(i).get_collider()
		if other and other.is_in_group("bounce_pad"):
			return   # don't count standing on bodies as safe ground
	last_safe = global_position


# ---------------- NAIL ATTACK ----------------
func _attack() -> void:
	attack_cd = ATTACK_COOLDOWN
	var dir := Vector2(facing, 0)
	if not is_on_floor() and Input.is_action_pressed("move_down"):
		dir = Vector2.DOWN
	elif Input.is_action_pressed("move_up"):
		dir = Vector2.UP
	slash_dir = dir
	slash_t = 0.12
	sfx_slash.play()

	var rect := RectangleShape2D.new()
	var offset := Vector2.ZERO
	if dir == Vector2.DOWN:
		rect.size = Vector2(18, 24)
		offset = Vector2(0, 10)
	elif dir == Vector2.UP:
		rect.size = Vector2(16, 18)
		offset = Vector2(0, -26)
	else:
		rect.size = Vector2(22, 14)
		offset = Vector2(facing * 15, -8)

	var q := PhysicsShapeQueryParameters2D.new()
	q.shape = rect
	q.transform = Transform2D(0.0, global_position + offset)
	q.collide_with_areas = true
	q.collide_with_bodies = true
	q.exclude = [get_rid()]
	var hits := get_world_2d().direct_space_state.intersect_shape(q, 16)

	var gm = get_tree().get_first_node_in_group("game_manager")
	var hit_something := false
	var done := {}
	for h in hits:
		var col = h.collider
		if col == null or done.has(col):
			continue
		done[col] = true
		if col.is_in_group("bounce_pad"):
			hit_something = true
			if gm: gm.reclaim_geo(col)
			col.squish()
		elif col.get_script() and col.get_script().resource_path.ends_with("killzone.gd"):
			hit_something = true          # spikes / enemies: pogo-able
			var enemy = col.get_parent()
			if enemy != get_tree().current_scene and gm:
				gm.hit_enemy(enemy, self)
	if hit_something:
		if dir == Vector2.DOWN:
			velocity.y = POGO_VELOCITY       # POGO!
			can_air_dash = true
			invuln = maxf(invuln, 0.15)
			sfx_bounce.pitch_scale = 1.3
			sfx_bounce.play()
			_squash()
		elif dir.x != 0:
			velocity.x = -facing * 120.0     # nail recoil


# BOUNCE BACK: landed on top of one of your old bodies? Launch!
func _check_bounce() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var other = c.get_collider()
		if other and other.is_in_group("bounce_pad") and c.get_normal().y < -0.5:
			velocity.y = BOUNCE_VELOCITY
			if Input.is_action_pressed("jump"):
				velocity.y *= BOUNCE_BOOST
			can_air_dash = true
			other.squish()
			sfx_bounce.pitch_scale = randf_range(0.95, 1.15)
			sfx_bounce.play()
			_squash()
			return


func _squash() -> void:
	var tw := create_tween()
	animated_sprite.scale = Vector2(0.7, 1.35)
	tw.tween_property(animated_sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	if slash_t <= 0.0:
		return
	var a := slash_t / 0.12
	var col := Color(1, 1, 1, a)
	if slash_dir == Vector2.DOWN:
		draw_arc(Vector2(0, 2), 14.0, deg_to_rad(20), deg_to_rad(160), 12, col, 3.0)
	elif slash_dir == Vector2.UP:
		draw_arc(Vector2(0, -16), 14.0, deg_to_rad(200), deg_to_rad(340), 12, col, 3.0)
	else:
		var c := Vector2(facing * 6, -8)
		var start := -60.0 if facing > 0 else 120.0
		draw_arc(c, 14.0, deg_to_rad(start), deg_to_rad(start + 120.0), 12, col, 3.0)


# ---------------- Called by the game manager ----------------
func take_hit(from_pos: Vector2) -> void:
	invuln = 1.0
	stun = 0.2
	var side := 1.0 if global_position.x >= from_pos.x else -1.0
	velocity = Vector2(KNOCKBACK.x * side, KNOCKBACK.y)
	animated_sprite.modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)
	sfx_hurt.play()


func die() -> void:
	controllable = false
	velocity = Vector2.ZERO
	collision.set_deferred("disabled", true)
	animated_sprite.modulate = Color(1, 0.4, 0.4)
	animated_sprite.pause()
	sfx_hurt.play()


func respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	dash_t = 0.0
	stun = 0.0
	collision.set_deferred("disabled", false)
	animated_sprite.modulate = Color.WHITE
	controllable = true
	invuln = 0.8
