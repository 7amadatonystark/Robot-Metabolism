# ORIGIN: NEW, written by team (AI-assisted). Uses the Brackeys tileset (CC0).
# BOSS ARENA: "The Throne". Builds the room out of Brackeys tiles, then wakes the Slime King.
extends Node2D

const TILESET = preload("res://assets/world_tileset.tres")
const SlimeKing = preload("res://scripts/slime_king.gd")
const BENCH = preload("res://scenes/checkpoint.tscn")

const W := 40          # arena width in tiles
const H := 14          # wall height in tiles
const STONE_TOP := Vector2i(8, 0)
const STONE := Vector2i(8, 1)
const BRICK_TOP := Vector2i(5, 0)
const BG_DARK := Vector2i(3, 15)
const BG_MID := Vector2i(3, 13)

var tilemap: TileMap


func _ready() -> void:
	_build_room()
	var bench = BENCH.instantiate()
	bench.position = Vector2(4 * 16, 0)
	add_child(bench)
	var king = SlimeKing.new()
	king.position = Vector2(W * 16 * 0.7, 0)
	king.left_x = 2 * 16 + 30
	king.right_x = (W - 2) * 16 - 30
	add_child(king)


func _build_room() -> void:
	tilemap = TileMap.new()
	tilemap.tile_set = TILESET
	tilemap.add_layer(-1)   # layer 1 = solid
	add_child(tilemap)
	move_child(tilemap, 0)
	# background
	for x in range(-10, W + 10):
		for y in range(-H - 8, 6):
			var tile := BG_DARK if y > -H + 3 else BG_MID
			tilemap.set_cell(0, Vector2i(x, y), 0, tile)
	# floor (2 rows) + walls
	for x in range(0, W):
		tilemap.set_cell(1, Vector2i(x, 0), 0, STONE_TOP)
		for y in range(1, 4):
			tilemap.set_cell(1, Vector2i(x, y), 0, STONE)
	for y in range(-H, 1):
		for x in [0, 1, W - 2, W - 1]:
			tilemap.set_cell(1, Vector2i(x, y), 0, STONE)
	# floating platforms (pink brick = the old castle)
	for p in [[7, -4, 4], [W - 11, -4, 4], [17, -8, 6]]:
		for x in range(p[0], p[0] + p[2]):
			tilemap.set_cell(1, Vector2i(x, p[1]), 0, BRICK_TOP)
