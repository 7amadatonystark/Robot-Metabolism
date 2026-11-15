# GAME MANAGER: coins, deaths, respawning, and leaving bodies behind.
# THE TWIST: every time you die, your body stays as a BOUNCE PAD. Use your failures to bounce back higher.
extends Node

const BodyPad = preload("res://scripts/body_pad.gd")
const FONT = preload("res://assets/fonts/PixelOperator8-Bold.ttf")
const MAX_BODIES := 25

var score = 0
var deaths := 0
var respawn_point := Vector2.ZERO
var dead := false
var player: CharacterBody2D
var bodies: Array = []
var death_label: Label

@onready var score_label = $ScoreLabel


func _ready():
	add_to_group("game_manager")
	_build_hud()
	await get_tree().process_frame          # wait for the whole level to load
	player = get_tree().get_first_node_in_group("player")
	if player:
		respawn_point = player.global_position


func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins."


func set_checkpoint(pos: Vector2) -> void:
	respawn_point = pos
	_toast("CHECKPOINT!")


func player_died(leave_body := true) -> void:
	if dead or player == null:
		return
	dead = true
	deaths += 1
	var where := player.global_position
	var facing_left: bool = player.animated_sprite.flip_h
	player.die()
	_update_hud()
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.3).timeout   # 0.6 s of slow-mo
	Engine.time_scale = 1.0
	if leave_body:
		_spawn_body(where, facing_left)
	player.respawn(respawn_point)
	dead = false


func _spawn_body(pos: Vector2, facing_left: bool) -> void:
	var b = BodyPad.new()
	b.frames = player.animated_sprite.sprite_frames
	b.flip = facing_left
	b.global_position = pos
	get_tree().current_scene.add_child(b)
	bodies.append(b)
	if bodies.size() > MAX_BODIES:
		bodies.pop_front().queue_free()


# ---------------- HUD ----------------
func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	death_label = Label.new()
	death_label.add_theme_font_override("font", FONT)
	death_label.add_theme_font_size_override("font_size", 16)
	death_label.add_theme_color_override("font_outline_color", Color.BLACK)
	death_label.add_theme_constant_override("outline_size", 6)
	death_label.position = Vector2(12, 8)
	layer.add_child(death_label)
	_update_hud()


func _update_hud() -> void:
	if deaths == 0:
		death_label.text = "Deaths: 0"
	else:
		death_label.text = "Deaths: %d  (each one is a step up)" % deaths


func _toast(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 4)
	get_tree().current_scene.add_child(l)
	l.global_position = player.global_position + Vector2(-30, -40)
	var tw := l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 20, 0.8)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.8)
	tw.tween_callback(l.queue_free)
