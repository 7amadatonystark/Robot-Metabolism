extends SceneTree
var failures := 0
func _initialize() -> void:
	_run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _run() -> void:
	check(ResourceLoader.exists("res://scenes/intro.tscn"), "intro scene exists")
	if failures:
		print("RESULT: FAIL (intro missing)")
		quit(1)
		return
	change_scene_to_file("res://scenes/intro.tscn")
	await process_frame
	await process_frame
	var intro = current_scene
	check(intro.story_label.text == intro.Levels.STORY[0], "first story line shown")
	var echo := InputEventKey.new()
	echo.pressed = true
	echo.echo = true
	echo.physical_keycode = KEY_SPACE
	intro._unhandled_input(echo)
	check(intro.line_index == 0, "echo cannot skip story")
	var cross := InputEventJoypadButton.new()
	cross.pressed = true
	cross.button_index = JOY_BUTTON_A
	for i in intro.Levels.STORY.size():
		intro._unhandled_input(cross)
		check(intro.story_label.visible_ratio == 1.0, "press reveals complete line")
		intro._unhandled_input(cross)
	check(intro.starting, "final line starts game once")
	for i in 30:
		await process_frame
		if current_scene and current_scene.scene_file_path == "res://scenes/story_level.tscn":
			break
	check(current_scene != null and current_scene.scene_file_path == "res://scenes/story_level.tscn", "intro reaches story")
	check(Engine.get_meta("level_index") == 1, "intro begins level one")
	root.get_node("Music").stop()
	await create_timer(0.1).timeout
	print("RESULT: ", "PASS" if failures == 0 else "FAIL", " (intro)")
	quit(0 if failures == 0 else 1)
