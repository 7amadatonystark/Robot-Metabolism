# ORIGIN: NEW, written by team (AI-assisted). Not from the tutorial.
# CHECKPOINT: walk through it and you respawn here from now on.
# Use: add an Area2D with a CollisionShape2D to the level, attach this script.
extends Area2D

var active := false


func _ready() -> void:
	collision_mask = 2   # the player's layer
	body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if active or not body.is_in_group("player"):
		return
	active = true
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.set_checkpoint(global_position)
	queue_redraw()


func _draw() -> void:
	# simple flag: pole + triangle (green when active)
	draw_line(Vector2(0, 0), Vector2(0, -20), Color(0.9, 0.9, 0.9), 2.0)
	var col := Color(0.3, 0.9, 0.4) if active else Color(0.8, 0.3, 0.3)
	draw_colored_polygon(PackedVector2Array([Vector2(1, -20), Vector2(12, -16), Vector2(1, -12)]), col)
