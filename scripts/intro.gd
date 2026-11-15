# ORIGIN: NEW, written by team (AI-assisted).
extends Control
## One fresh press reveals the current line; another advances the story.
const Levels = preload("res://scripts/levels.gd")
const FONT = preload("res://assets/fonts/PixelOperator8-Bold.ttf")
var line_index := 0
var starting := false
var story_label: Label
var prompt: Label
var reveal: Tween

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 32)
	add_child(column)
	story_label = Label.new()
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_label.add_theme_font_override("font", FONT)
	story_label.add_theme_font_size_override("font_size", 24)
	column.add_child(story_label)
	prompt = Label.new()
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_override("font", FONT)
	prompt.add_theme_font_size_override("font_size", 12)
	prompt.modulate = Color(1, 0.85, 0.5)
	column.add_child(prompt)
	_show_line()

func _show_line() -> void:
	story_label.text = Levels.STORY[line_index]
	story_label.visible_ratio = 0.0
	prompt.text = "Press any key / CROSS   (%d/%d)" % [line_index + 1, Levels.STORY.size()]
	reveal = create_tween()
	reveal.tween_property(story_label, "visible_ratio", 1.0, story_label.text.length() * 0.035)

func _unhandled_input(event: InputEvent) -> void:
	var key: bool = event is InputEventKey and event.pressed and not event.echo
	var cross: bool = event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_A
	var click: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if starting or not (key or cross or click):
		return
	get_viewport().set_input_as_handled()
	if story_label.visible_ratio < 1.0:
		reveal.kill()
		story_label.visible_ratio = 1.0
	elif line_index + 1 < Levels.STORY.size():
		line_index += 1
		_show_line()
	else:
		starting = true
		Engine.set_meta("level_index", 1)
		_start_story.call_deferred()

func _start_story() -> void:
	var error := get_tree().change_scene_to_file("res://scenes/story_level.tscn")
	if error != OK:
		starting = false
		prompt.text = "Unable to start. Press any key / CROSS to retry."
		push_error("Intro could not load story level: %d" % error)
