# ORIGIN: NEW, demo-recording script (AI-assisted).
# Record: godot --path . --write-movie demo.avi -s tests/demo_vice.gd
extends SceneTree

func _initialize():
	change_scene_to_file("res://scenes/boss_arena.tscn")

var f := 0
var gm
var pl
var king
var pogo_next := 0
var deaths_done := 0

func press(a, on):
	if on: Input.action_press(a)
	else: Input.action_release(a)

func _physics_process(_d):
	f += 1
	if f == 5:
		gm = get_first_node_in_group("game_manager")
		pl = get_first_node_in_group("player")
		for n in current_scene.get_children():
			if n.get_script() and n.get_script().resource_path.ends_with("slime_king.gd"):
				king = n
		gm.score = 8
	if gm == null or king == null:
		return false
	# 1) walk toward the king
	if f > 150 and f < 260:
		press("move_right", true)
	if f == 260:
		press("move_right", false)
	# 2) die twice (to show BOUNCED + bodies), at different spots
	if f == 300 or f == 520:
		pl.global_position = Vector2(king.global_position.x - 70 - deaths_done * 40, pl.global_position.y)
		gm.masks = 1
		pl.invuln = 0.0
		gm.player_hit(king.global_position)
		deaths_done += 1
	# 3) side hit: CLANK
	if f == 700:
		pl.global_position = king.global_position + Vector2(-26, 0)
		pl.facing = 1
		pl.invuln = 2.0
		pl.attack_cd = 0
		pl._attack()
	# 4) pogo the king until he dies
	if f > 760 and not king.dead and f >= pogo_next:
		pl.global_position = king.global_position + Vector2(0, -58)
		pl.velocity = Vector2.ZERO
		pl.invuln = 2.0
		pogo_next = f + 34
	if f > 760 and not king.dead and f == pogo_next - 28:
		press("move_down", true)
		pl.attack_cd = 0
		pl._attack()
		press("move_down", false)
	if f > 1900:
		quit()
	return false
