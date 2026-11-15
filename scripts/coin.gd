extends Area2D

@onready var game_manager = get_tree().get_first_node_in_group("game_manager")   # (was %GameManager: missing in built levels)
@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	game_manager.add_point()
	animation_player.play("pickup")
