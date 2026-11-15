# ORIGIN: Brackeys tutorial (human-written): Area2D that hurts on touch.
# MODIFIED BY TEAM (AI-assisted): now costs 1 MASK instead of reloading the level (Hollow Knight style).
#   leaves_body = true  -> enemy (slime): knockback + lose a mask
#   leaves_body = false -> hazard (spikes, pits): lose a mask + respawn at last safe ground
extends Area2D

@export var leaves_body := true

@onready var timer = $Timer


func _on_body_entered(body):
	if body.is_in_group("player"):
		var gm = get_tree().get_first_node_in_group("game_manager")
		if gm:
			gm.player_hit(global_position, not leaves_body)


func _on_timer_timeout():
	pass   # kept so the old signal connection in killzone.tscn still works
