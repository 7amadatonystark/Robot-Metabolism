# The player robot. Move with WASD / arrows, or hold the mouse button.
# DASH with Space or right mouse button.
extends Node2D

const DB = preload("res://scripts/parts_db.gd")
const Draw = preload("res://scripts/robot_draw.gd")

var game                       # the main.gd node (set when spawned)
var parts: Array = []          # list of part kinds this robot is made of
var mut := {}                  # mutations picked, e.g. {"TWIN": true}
var core_color := Color.WHITE
var vel := Vector2.ZERO
var face := Vector2.RIGHT
var invuln := 0.0              # seconds of "can't be hurt" after a hit
var flash := 0.0
var fire_cd := 0.0
var dash_t := 0.0              # > 0 while dashing
var dash_cd := 0.0             # cooldown until next dash
var printer_t := 4.0
var boost_t := 0.0             # speed boost after a FULL BOUNCE BACK
var t := 0.0


func mass() -> int:
	return 1 + parts.size()

func count(kind: int) -> int:
	return parts.count(kind)

func radius() -> float:
	return 14.0 + 7.0 * sqrt(float(mass()))

# Power decides what you can eat. Claws count extra.
func power() -> int:
	var p := mass() + count(DB.CLAW)
	if mut.has("FEAST"):
		p = int(p * 1.25)
	return p

func speed() -> float:
	var s := (240.0 + 220.0 * (1.0 - exp(-count(DB.WHEEL) / 6.0))) / (1.0 + mass() * 0.004)
	return s * (1.4 if boost_t > 0.0 else 1.0)

func magnet_range() -> float:
	var r := 40.0 + 180.0 * (1.0 - exp(-count(DB.MAGNET) / 5.0))   # diminishing returns
	return r * (2.0 if mut.has("GRAVITY") else 1.0)

func dash_cooldown() -> float:
	return 1.0 if mut.has("OVERCLOCK") else 2.0

func is_dashing() -> bool:
	return dash_t > 0.0


func _process(delta: float) -> void:
	t += delta
	invuln = maxf(invuln - delta, 0.0)
	flash = maxf(flash - delta * 4.0, 0.0)
	dash_t = maxf(dash_t - delta, 0.0)
	dash_cd = maxf(dash_cd - delta, 0.0)
	boost_t = maxf(boost_t - delta, 0.0)
	modulate.a = 0.4 if (invuln > 0.0 and not is_dashing() and int(t * 20.0) % 2 == 0) else 1.0
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
	var want_dash := Input.is_physical_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	if game.autopilot:
		dir = game.autopilot_dir()
		want_dash = randf() < 0.01
	dir = dir.normalized()

	# DASH: short burst of speed, can't be hurt while dashing
	if want_dash and dash_cd <= 0.0:
		var d := dir if dir != Vector2.ZERO else face
		dash_t = 0.2
		dash_cd = dash_cooldown()
		vel = d * maxf(speed(), 260.0) * 3.4
		invuln = maxf(invuln, 0.3)
		game.on_dash(position, d)

	if is_dashing():
		game.dash_trail(position)
	else:
		vel = vel.lerp(dir * speed(), 1.0 - exp(-10.0 * delta))
	position += vel * delta
	# BOUNCY WALLS: hit the arena edge and you bounce back
	var a: float = game.ARENA_HALF
	if absf(position.x) > a:
		position.x = clampf(position.x, -a, a)
		vel.x = -vel.x * 0.9
		game.on_wall_bounce(position, vel.length())
	if absf(position.y) > a:
		position.y = clampf(position.y, -a, a)
		vel.y = -vel.y * 0.9
		game.on_wall_bounce(position, vel.length())
	if dir != Vector2.ZERO:
		face = face.lerp(dir, 1.0 - exp(-12.0 * delta)).normalized()

	# Cannons shoot by themselves at the closest enemy
	var cannons := count(DB.CANNON)
	fire_cd -= delta
	if cannons > 0 and fire_cd <= 0.0:
		var target = game.nearest_enemy(position, 520.0)
		if target:
			var aim: Vector2 = (target.position - position).normalized()
			game.spawn_bullet(position, aim, true, 10.0)
			if mut.has("TWIN"):
				game.spawn_bullet(position, aim.rotated(0.22), true, 10.0)
				game.spawn_bullet(position, aim.rotated(-0.22), true, 10.0)
			fire_cd = maxf(0.12, 0.9 / float(cannons))

	# SCRAP PRINTER mutation: free part every 4 s
	if mut.has("PRINTER"):
		printer_t -= delta
		if printer_t <= 0.0:
			printer_t = 4.0
			var k := randi() % DB.COUNT
			parts.append(k)
			game.float_text(position, "PRINTED " + DB.NAMES[k], DB.COLORS[k])


func _draw() -> void:
	if game and game.is_playing() and count(DB.MAGNET) > 0:
		draw_arc(Vector2.ZERO, radius() + magnet_range(), 0.0, TAU, 48, Color(DB.COLORS[DB.MAGNET], 0.15), 2.0)
	if is_dashing():
		draw_circle(Vector2.ZERO, radius() * 1.15, Color(0, 0.9, 1, 0.25))
	if boost_t > 0.0:
		draw_arc(Vector2.ZERO, radius() * 1.25, 0.0, TAU, 32, Color("ffd54f"), 3.0)
	if game and game.reboot_t > 0.0:
		var pulse := 0.5 + 0.5 * sin(t * 18.0)
		draw_arc(Vector2.ZERO, radius() * 1.6, 0.0, TAU, 32, Color(1, 0.3, 0.3, pulse), 4.0)
	Draw.draw_robot(self, parts, radius(), core_color, t, face, Color("00e5ff"), flash)
