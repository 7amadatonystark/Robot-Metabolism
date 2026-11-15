# ORIGIN: Brackeys tutorial (human-written): Area2D that kills on touch.
# MODIFIED BY TEAM (AI-assisted): calls game_manager instead of reloading; leaves_body option.
# KILLZONE: touch it and you die.
# leaves_body = true  -> your body stays here as a bounce pad (spikes, slimes...)
# leaves_body = false -> no body (use this for bottomless pits)
extends Area2D

@export var leaves_body := true

@onready var timer = $Timer


func _on_body_entered(body):
	if body.is_in_group("player"):
		var gm = get_tree().get_first_node_in_group("game_manager")
		if gm:
			gm.player_died(leaves_body)


func _on_timer_timeout():
	pass   # kept so the old signal connection in killzone.tscn still works
