extends Node2D

var vel := Vector2.ZERO
var friendly := true    # true = shot by the player
var dmg := 10.0
var life := 1.4


func _process(delta: float) -> void:
	position += vel * delta
	life -= delta
	queue_redraw()


func _draw() -> void:
	var col := Color("fff176") if friendly else Color("ff5252")
	draw_line(Vector2.ZERO, -vel.normalized() * 14.0, Color(col, 0.4), 4.0)
	draw_circle(Vector2.ZERO, 5.0, col)
