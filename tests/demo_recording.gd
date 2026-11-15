# ORIGIN: NEW, demo-recording script written by team (AI-assisted).
# Records the gameplay demo: DX=40 godot --path . --write-movie demo.avi -s tests/demo_recording.gd
# Scripted demo: walk into slime, die, respawn, jump on own body, BOUNCE.
extends SceneTree
func _initialize():
	change_scene_to_file("res://scenes/game.tscn")
var f := 0
var phase := 0
var gm
var pl
var slime
var START_DX = float(OS.get_environment("DX"))
func press(a, on):
	if on: Input.action_press(a)
	else: Input.action_release(a)
func _physics_process(_d):
	f += 1
	if f == 5:
		gm = get_first_node_in_group("game_manager")
		pl = get_first_node_in_group("player")
		slime = current_scene.get_node("Slime")
		print("slime at ", slime.global_position, " player ", pl.global_position)
	if f == 8:
		var start = Vector2(slime.global_position.x + START_DX, slime.global_position.y - 4)
		pl.global_position = start
		gm.respawn_point = start
	if f > 8 and phase == 0:
		press("move_left" if START_DX > 0 else "move_right", true)
		if gm.deaths >= 1:
			press("move_right", false); press("move_left", false); phase = 1; print("died at f", f)
	if phase == 1 and pl.controllable and gm.bodies.size() > 0:
		phase = 2; print("respawned f", f)
	if phase == 2:
		var b = gm.bodies[0].global_position
		var dx = b.x - pl.global_position.x
		if absf(dx) > 26:
			press("move_right" if dx > 0 else "move_left", true)
		elif false:
			press("move_right", true)
		else:
			press("move_right", false)
			press("move_left", false)
			press("jump", true)
			phase = 3; print("jump f", f)
	if phase == 3:
		if pl.velocity.y < -350: print("BOUNCE f", f, " vy ", pl.velocity.y); phase = 4
	if phase == 4:
		press("jump", false)
		if pl.is_on_floor() and pl.velocity.y >= 0:
			phase = 5
	if phase == 5:
		press("move_left", true)
		if f % 40 == 0: press("jump", true)
		elif f % 40 == 10: press("jump", false)
	if f % 30 == 0: print(f, " pos ", pl.global_position, " deaths ", gm.deaths)
	if f > 540: quit()
	return false
