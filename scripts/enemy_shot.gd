# ORIGIN: NEW, written by team (AI-assisted).
# ENEMY SHOT: the scalper's thrown price tag. Hurts the first player it touches.
extends Node2D

const FONT = preload("res://assets/fonts/PixelOperator8-Bold.ttf")
var velocity := Vector2.ZERO
var life := 2.5
var spin := 0.0


func _physics_process(delta: float) -> void:
	life -= delta
	spin += delta * 10.0
	position += velocity * delta
	queue_redraw()
	if life <= 0.0:
		queue_free()
		return
	for p in get_tree().get_nodes_in_group("player"):
		if not p.is_dead and p.global_position.distance_to(global_position + Vector2(0, 6)) < 10.0:
			var gm = get_tree().get_first_node_in_group("game_manager")
			if gm:
				gm.player_hit(global_position, false, p)
			queue_free()
			return


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, sin(spin) * 0.5, Vector2.ONE)
	draw_rect(Rect2(-7, -4, 14, 8), Color(1, 0.95, 0.6))
	draw_rect(Rect2(-7, -4, 14, 8), Color(0.3, 0.2, 0.1), false, 1.0)
	draw_string(FONT, Vector2(-6, 3), "$$$", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.2, 0.5, 0.2))
