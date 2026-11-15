extends SceneTree
var failures := 0
func _initialize() -> void:
	_run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func scene(path: String) -> void:
	change_scene_to_file(path)
	for i in 5:
		await process_frame
func key(code: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
func pad(code: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = code
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
func _run() -> void:
	Input.use_accumulated_input = false
	var menu := root.get_node_or_null("PauseMenu")
	check(menu != null, "PauseMenu autoload exists")
	if not menu:
		print("RESULT: FAIL (pause missing)")
		quit(1)
		return
	await scene("res://scenes/character_select.tscn")
	key(KEY_ESCAPE)
	check(not paused, "fighter select cannot pause")
	await scene("res://scenes/game.tscn")
	key(KEY_ESCAPE)
	check(paused and menu.overlay.visible, "Escape pauses gameplay")
	check(menu.resume_button.has_focus(), "Resume receives keyboard/pad focus")
	pad(JOY_BUTTON_DPAD_DOWN)
	await process_frame
	check(menu.restart_button.has_focus(), "d-pad moves button focus")
	pad(JOY_BUTTON_B)
	check(not paused and not menu.overlay.visible, "CIRCLE resumes")
	pad(JOY_BUTTON_START)
	check(paused, "OPTIONS pauses")
	key(KEY_ESCAPE)
	check(not paused, "Escape resumes")
	menu.open_pause()
	var gm := get_first_node_in_group("game_manager")
	gm.player_died(false, gm.player)
	check(Engine.time_scale == 0.5, "death slow-motion is active before restart")
	var previous := current_scene.get_instance_id()
	menu.restart_button.pressed.emit()
	for i in 5:
		await process_frame
	check(not paused and current_scene.get_instance_id() != previous, "restart reloads and unpauses")
	check(Engine.time_scale == 1.0, "restart clears outgoing death slow-motion")
	gm = get_first_node_in_group("game_manager")
	gm.player_died(false, gm.player)
	menu.open_pause()
	menu.fighter_button.pressed.emit()
	for i in 5:
		await process_frame
	check(not paused and current_scene.scene_file_path.ends_with("character_select.tscn"), "fighter change unpauses")
	check(Engine.time_scale == 1.0, "fighter change clears outgoing death slow-motion")
	Engine.time_scale = 1.0
	Engine.set_meta("raid", [{"device": -2, "char": "spark"}, {"device": 0, "char": "zoom"}])
	await scene("res://scenes/boss_arena.tscn")
	pad(JOY_BUTTON_START)
	check(paused, "OPTIONS pauses co-op boss")
	menu.close_pause()
	Engine.set_meta("raid", [])
	root.get_node("Music").stop()
	await create_timer(0.1).timeout
	print("RESULT: ", "PASS" if failures == 0 else "FAIL", " (pause)")
	quit(0 if failures == 0 else 1)
