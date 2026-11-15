# "+SPEED", "CHOMP!" popups that float up and fade.
extends Node2D

var text := ""
var color := Color.WHITE
var size := 22
var life := 1.0
const FONT = preload("res://fonts/Bungee-Regular.ttf")


func _process(delta: float) -> void:
	life -= delta
	position.y -= 50.0 * delta
	modulate.a = clampf(life * 2.0, 0.0, 1.0)
	if life <= 0.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var font: Font = FONT
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var p := Vector2(-w * 0.5, 0)
	draw_string_outline(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 6, Color.BLACK)
	draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
