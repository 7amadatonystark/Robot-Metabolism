# BODY PAD: what's left when you die. It's solid, and it BOUNCES you up.
# Created by game_manager.gd. You don't place these by hand.
extends StaticBody2D

var frames: SpriteFrames      # the player's sprites (set before adding to the scene)
var flip := false
var sprite: AnimatedSprite2D


func _ready() -> void:
	add_to_group("bounce_pad")
	collision_layer = 1           # same layer as the ground, so the player stands/bounces on it
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 6)
	shape.shape = rect
	shape.position = Vector2(0, -3)
	add_child(shape)

	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.animation = "idle"
	sprite.frame = 0
	sprite.flip_h = flip
	sprite.rotation_degrees = -90.0 if flip else 90.0   # lying down
	sprite.position = Vector2(0, -6)
	sprite.modulate = Color(0.75, 0.9, 1.0, 0.85)       # ghosty blue
	add_child(sprite)

	# pop in
	scale = Vector2(0.2, 0.2)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# Called by the player when they bounce on this body
func squish() -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "scale", Vector2(1.3, 0.6), 0.06)
	tw.tween_property(sprite, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
