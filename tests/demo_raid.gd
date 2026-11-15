# ORIGIN: NEW, demo-recording script (AI-assisted). Lobby -> 3-player boss raid.
extends SceneTree
func _initialize():
	change_scene_to_file("res://scenes/raid_lobby.tscn")
var f := 0
var gm
var ps: Array = []
var king
func _physics_process(_d):
	f += 1
	var lobby = current_scene
	if f == 30: lobby._join(-2)
	if f == 55: lobby._join(0)
	if f == 70: lobby._cycle(0, 1)
	if f == 85: lobby._join(1)
	if f == 100: lobby._cycle(1, 1)
	if f == 115: lobby._cycle(1, 1)
	if f == 150: lobby._start()
	if f == 200:
		gm = get_first_node_in_group("game_manager"); ps = gm.players
		for n in current_scene.get_children():
			if n.get_script() and n.get_script().resource_path.ends_with("slime_king.gd"): king = n
	if king == null: return false
	# everyone runs at the boss
	if f > 330 and f < 420:
		Input.action_press("kb_move_right"); Input.action_press("p0_move_right"); Input.action_press("p1_move_right")
	if f == 420:
		for a in ["kb_move_right", "p0_move_right", "p1_move_right"]: Input.action_release(a)
	# P2 (brute) smashes from the side, P3 gets flattened, P1 pogos
	if f > 430 and not king.dead:
		var t := (f - 430) % 50
		if t == 0:
			ps[1].global_position = king.global_position + Vector2(-34, 0); ps[1].facing = 1; ps[1].invuln = 1.0; ps[1].attack_cd = 0; ps[1]._attack()
		if t == 10:
			ps[0].global_position = king.global_position + Vector2(0, -60); ps[0].velocity = Vector2.ZERO; ps[0].invuln = 1.5
		if t == 16:
			Input.action_press("kb_move_down"); ps[0].attack_cd = 0; ps[0]._attack(); Input.action_release("kb_move_down")
	if f == 470:
		for i in 6:
			ps[2].invuln = 0.0; gm.player_hit(king.global_position, false, ps[2])
	if f > 1500: quit()
	return false
