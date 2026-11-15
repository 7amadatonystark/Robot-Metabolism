extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const BOUNCE_VELOCITY = -420.0     # landing on one of your old bodies
const BOUNCE_BOOST = 1.2           # hold jump while bouncing = go even higher

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var controllable := true

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
var sfx_jump: AudioStreamPlayer
var sfx_hurt: AudioStreamPlayer
var sfx_bounce: AudioStreamPlayer


func _ready():
	add_to_group("player")
	sfx_jump = _make_sfx("res://assets/sounds/jump.wav")
	sfx_hurt = _make_sfx("res://assets/sounds/hurt.wav")
	sfx_bounce = _make_sfx("res://assets/sounds/power_up.wav")


func _make_sfx(path: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	add_child(p)
	return p


func _physics_process(delta):
	if not controllable:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sfx_jump.play()

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")

	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

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


# BOUNCE BACK: landed on top of one of your old bodies? Launch!
func _check_bounce() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var other = c.get_collider()
		if other and other.is_in_group("bounce_pad") and c.get_normal().y < -0.5:
			velocity.y = BOUNCE_VELOCITY
			if Input.is_action_pressed("jump"):
				velocity.y *= BOUNCE_BOOST
			other.squish()
			sfx_bounce.pitch_scale = randf_range(0.95, 1.15)
			sfx_bounce.play()
			_squash()
			return


func _squash() -> void:
	var tw := create_tween()
	animated_sprite.scale = Vector2(0.7, 1.35)
	tw.tween_property(animated_sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


# Called by the game manager
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
	collision.set_deferred("disabled", false)
	animated_sprite.modulate = Color.WHITE
	controllable = true
	# blink so you see where you came back
	var tw := create_tween()
	for i in 3:
		tw.tween_property(animated_sprite, "modulate:a", 0.2, 0.08)
		tw.tween_property(animated_sprite, "modulate:a", 1.0, 0.08)
