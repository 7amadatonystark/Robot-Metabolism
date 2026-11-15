# The player robot. Move with WASD / arrows, or hold the mouse button.
extends Node2D

const DB = preload("res://scripts/parts_db.gd")
const Draw = preload("res://scripts/robot_draw.gd")

var game                       # the main.gd node (set when spawned)
var parts: Array = []          # list of part kinds this robot is made of
var core_color := Color.WHITE
var vel := Vector2.ZERO
var face := Vector2.RIGHT
var invuln := 0.0              # seconds of "can't be hurt" after a hit
var flash := 0.0
var fire_cd := 0.0
var t := 0.0


func mass() -> int:
	return 1 + parts.size()

func count(kind: int) -> int:
	return parts.count(kind)

func radius() -> float:
	return 14.0 + 7.0 * sqrt(float(mass()))

# Power decides what you can eat. Claws count extra.
func power() -> int:
	return mass() + count(DB.CLAW)

func speed() -> float:
	return (240.0 + 220.0 * (1.0 - exp(-count(DB.WHEEL) / 6.0))) / (1.0 + mass() * 0.004)

func magnet_range() -> float:
	return 40.0 + 180.0 * (1.0 - exp(-count(DB.MAGNET) / 5.0))   # diminishing returns


func _process(delta: float) -> void:
	t += delta
	invuln = maxf(invuln - delta, 0.0)
	flash = maxf(flash - delta * 4.0, 0.0)
	modulate.a = 0.4 if (invuln > 0.0 and int(t * 20.0) % 2 == 0) else 1.0
	queue_redraw()
	if not game.is_playing():
		return

	var dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): dir.x += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): dir.x -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): dir.y += 1
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): dir.y -= 1
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var to_mouse := get_global_mouse_position() - global_position
		if to_mouse.length() > 12.0:
			dir = to_mouse
	if game.autopilot:
		dir = game.autopilot_dir()
	dir = dir.normalized()

	vel = vel.lerp(dir * speed(), 1.0 - exp(-10.0 * delta))
	position += vel * delta
	position = position.clamp(Vector2.ONE * -game.ARENA_HALF, Vector2.ONE * game.ARENA_HALF)
	if dir != Vector2.ZERO:
		face = face.lerp(dir, 1.0 - exp(-12.0 * delta)).normalized()

	# Cannons shoot by themselves at the closest enemy
	var cannons := count(DB.CANNON)
	fire_cd -= delta
	if cannons > 0 and fire_cd <= 0.0:
		var target = game.nearest_enemy(position, 520.0)
		if target:
			game.spawn_bullet(position, (target.position - position).normalized(), true, 10.0)
			fire_cd = maxf(0.12, 0.9 / float(cannons))


func _draw() -> void:
	if game and game.is_playing() and count(DB.MAGNET) > 0:
		draw_arc(Vector2.ZERO, radius() + magnet_range(), 0.0, TAU, 48, Color(DB.COLORS[DB.MAGNET], 0.15), 2.0)
	Draw.draw_robot(self, parts, radius(), core_color, t, face, Color("00e5ff"), flash)
