# A loose part lying on the floor. Touch it to bolt it onto your robot.
extends Node2D

const DB = preload("res://scripts/parts_db.gd")
const Draw = preload("res://scripts/robot_draw.gd")

var game
var kind := 0
var vel := Vector2.ZERO
var t := 0.0
var pickup_delay := 0.0   # so parts knocked off you don't instantly come back


func _process(delta: float) -> void:
	t += delta
	pickup_delay = maxf(pickup_delay - delta, 0.0)
	vel *= exp(-3.0 * delta)
	if game.is_playing() and pickup_delay <= 0.0 and game.player:
		var to: Vector2 = game.player.position - position
		if to.length() < game.player.radius() + game.player.magnet_range():
			vel = vel.lerp(to.normalized() * 520.0, 1.0 - exp(-8.0 * delta))
	position += vel * delta
	queue_redraw()


func _draw() -> void:
	var col: Color = DB.COLORS[kind]
	var bob := 1.0 + 0.12 * sin(t * 5.0)
	draw_circle(Vector2.ZERO, 15.0 * bob, Color(col, 0.15))
	Draw.draw_part(self, kind, Vector2.ZERO, 8.0 * bob, t * 1.5, t)
