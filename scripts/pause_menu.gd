# ORIGIN: NEW, written by team (AI-assisted).
extends CanvasLayer
## UI remains responsive while the whole shared gameplay screen is paused.
const FONT = preload("res://assets/fonts/PixelOperator8-Bold.ttf")
const GAME_SCENES := ["res://scenes/game.tscn", "res://scenes/story_level.tscn", "res://scenes/boss_arena.tscn"]
var overlay: Control
var resume_button: Button
var restart_button: Button
var fighter_button: Button
var buttons: VBoxContainer
var _scene_id := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 90
	_setup_pad_navigation()
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.hide()
	add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.025, 0.01, 0.04, 0.94)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	buttons = VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 16)
	center.add_child(buttons)
	var theme := Theme.new()
	theme.default_font = FONT
	theme.default_font_size = 16
	overlay.theme = theme
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.modulate = Color(1, 0.55, 0.8)
	buttons.add_child(title)
	resume_button = _button("RESUME", close_pause)
	restart_button = _button("RESTART LEVEL", _restart)
	fighter_button = _button("CHANGE FIGHTER", _change_fighter)
	var focus_order := [resume_button, restart_button, fighter_button]
	for i in focus_order.size():
		var button: Button = focus_order[i]
		var above: Button = focus_order[wrapi(i - 1, 0, focus_order.size())]
		var below: Button = focus_order[wrapi(i + 1, 0, focus_order.size())]
		button.focus_neighbor_top = button.get_path_to(above)
		button.focus_neighbor_bottom = button.get_path_to(below)
		button.focus_previous = button.get_path_to(above)
		button.focus_next = button.get_path_to(below)
	var hint := Label.new()
	hint.text = "ESC / OPTIONS: resume    CIRCLE: back"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 8)
	buttons.add_child(hint)

func _button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(330, 46)
	button.pressed.connect(action)
	buttons.add_child(button)
	return button

func _can_pause() -> bool:
	var scene := get_tree().current_scene
	return scene != null and scene.scene_file_path in GAME_SCENES

func _input(event: InputEvent) -> void:
	var toggle: bool = (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE) or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START)
	var back: bool = event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B
	if overlay.visible and (toggle or back):
		close_pause()
		get_viewport().set_input_as_handled()
	elif toggle and _can_pause():
		open_pause()
		get_viewport().set_input_as_handled()

func open_pause() -> void:
	if not _can_pause() or get_tree().paused:
		return
	_scene_id = get_tree().current_scene.get_instance_id()
	get_tree().paused = true
	buttons.show()
	overlay.show()
	resume_button.grab_focus()

func close_pause() -> void:
	buttons.show()
	overlay.hide()
	get_tree().paused = false

func _process(_delta: float) -> void:
	# Scene changes made elsewhere must never leave an invisible paused game.
	if overlay.visible:
		var scene := get_tree().current_scene
		if scene == null or scene.get_instance_id() != _scene_id:
			close_pause()

func _restart() -> void:
	close_pause()
	Engine.time_scale = 1.0
	var error := get_tree().reload_current_scene()
	if error != OK:
		push_error("Could not restart level: %d" % error)

func _change_fighter() -> void:
	close_pause()
	Engine.time_scale = 1.0
	var error := get_tree().change_scene_to_file("res://scenes/character_select.tscn")
	if error != OK:
		push_error("Could not change fighter: %d" % error)

func _setup_pad_navigation() -> void:
	# Do not assume built-in ui_* actions contain joypad events on every export.
	var bindings := {"ui_accept": JOY_BUTTON_A, "ui_up": JOY_BUTTON_DPAD_UP,
		"ui_down": JOY_BUTTON_DPAD_DOWN, "ui_left": JOY_BUTTON_DPAD_LEFT,
		"ui_right": JOY_BUTTON_DPAD_RIGHT}
	for action in bindings:
		var button := InputEventJoypadButton.new()
		button.device = -1
		button.button_index = bindings[action]
		if not InputMap.action_has_event(action, button):
			InputMap.action_add_event(action, button)
	var axes := {"ui_up": [JOY_AXIS_LEFT_Y, -1.0], "ui_down": [JOY_AXIS_LEFT_Y, 1.0],
		"ui_left": [JOY_AXIS_LEFT_X, -1.0], "ui_right": [JOY_AXIS_LEFT_X, 1.0]}
	for action in axes:
		var motion := InputEventJoypadMotion.new()
		motion.device = -1
		motion.axis = axes[action][0]
		motion.axis_value = axes[action][1]
		if not InputMap.action_has_event(action, motion):
			InputMap.action_add_event(action, motion)
