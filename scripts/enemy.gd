# Enemy robot. GREEN ring = you can eat it. RED ring = it can hurt you.
# Small ones run away, big ones chase you, and they eat scrap to grow too.
extends Node2D

const DB = preload("res://scripts/parts_db.gd")
const Draw = preload("res://scripts/robot_draw.gd")

var game
var parts: Array = []
var core_color := Color.GRAY
var vel := Vector2.ZERO
var face := Vector2.RIGHT
var hp := 10.0
var flash := 0.0
var t := 0.0
var wander := Vector2.ZERO
var wander_t := 0.0
var fire_cd := 2.0


func setup(m: int) -> void:
	parts.clear()
	for i in maxi(m - 1, 0):
		parts.append(randi() % DB.COUNT)
	hp = mass() * 8.0
	t = randf() * 10.0

func mass() -> int:
	return 1 + parts.size()

func count(kind: int) -> int:
	return parts.count(kind)

func radius() -> float:
	return 14.0 + 7.0 * sqrt(float(mass()))

# Speed is relative to the player: hunters are almost as fast as you, prey a bit slower.
func speed() -> float:
	var base: float = game.player.speed() if game.player else 200.0
	if game.is_attract():
		base = 200.0
	return base * (0.8 if edible() else 0.93)

func edible() -> bool:
	return game.player != null and game.player.power() > mass()


func _process(delta: float) -> void:
	t += delta
	flash = maxf(flash - delta * 5.0, 0.0)
	queue_redraw()
	var attract: bool = game.is_attract()   # title screen: just roam around
	if not game.is_playing() and not attract:
		return

	var to: Vector2 = game.player.position - position
	var d := to.length()
	var desired := Vector2.ZERO
	if d < 520.0 and not attract:
		desired = (-to if edible() else to).normalized()     # flee or chase
	else:
		wander_t -= delta
		if wander_t <= 0.0:
			wander = Vector2.from_angle(randf() * TAU)
			wander_t = randf_range(1.0, 3.0)
		desired = wander * 0.5
	vel = vel.lerp(desired * speed(), 1.0 - exp(-3.0 * delta))
	position += vel * delta
	position = position.clamp(Vector2.ONE * -game.ARENA_HALF, Vector2.ONE * game.ARENA_HALF)
	if vel.length() > 5.0:
		face = vel.normalized()

	# Dangerous enemies with cannons shoot back
	var cannons := count(DB.CANNON)
	if cannons > 0 and not edible() and d < 450.0 and not attract:
		fire_cd -= delta
		if fire_cd <= 0.0:
			game.spawn_bullet(position, to.normalized(), false, 1.0)
			fire_cd = 2.4 / float(cannons) + 0.4


func _draw() -> void:
	var ring := Color("69f0ae") if edible() else Color("ff5252")
	Draw.draw_robot(self, parts, radius(), core_color, t, face, ring, flash)
