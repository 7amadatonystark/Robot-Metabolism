# Draws robots and parts using the sprites in res://art/.
# Want to change the look? Just redraw the PNGs in art/ (same size, part points to the RIGHT).
extends RefCounted

const DB = preload("res://scripts/parts_db.gd")
const CORE_TEX = preload("res://art/core.png")
const PART_TEX = [
	preload("res://art/wheel.png"),
	preload("res://art/claw.png"),
	preload("res://art/magnet.png"),
	preload("res://art/cannon.png"),
]


static func draw_part(ci: CanvasItem, kind: int, p: Vector2, ps: float, ang: float, t: float) -> void:
	var rot := ang
	if kind == DB.WHEEL:
		rot = t * 6.0          # wheels spin
	var s := ps * 2.6
	ci.draw_set_transform(p, rot, Vector2.ONE)
	ci.draw_texture_rect(PART_TEX[kind], Rect2(-s * 0.5, -s * 0.5, s, s), false)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func draw_robot(ci: CanvasItem, parts: Array, r: float, core: Color, t: float,
		face: Vector2, ring: Color, flash: float) -> void:
	var n := mini(parts.size(), 36)   # only draw up to 36 parts so huge bots stay readable
	var ps := clampf(r * 0.3, 6.0, 18.0)
	for i in n:
		var layer := i % 2
		var spin := 0.6 if layer == 0 else -0.4
		var ang := float(i) * TAU / float(n) + t * spin
		var dist := r * (0.8 if layer == 0 else 1.0)
		draw_part(ci, parts[i], Vector2.from_angle(ang) * dist, ps, ang, t)
	var cr := r * 0.66
	# soft shadow
	ci.draw_circle(Vector2(0, cr * 0.15), cr * 1.02, Color(0, 0, 0, 0.35))
	ci.draw_texture_rect(CORE_TEX, Rect2(-cr, -cr, cr * 2.0, cr * 2.0), false, core)
	ci.draw_arc(Vector2.ZERO, cr * 0.94, 0.0, TAU, 40, ring, maxf(cr * 0.08, 2.5))
	# eye
	var eye := face * cr * 0.3
	ci.draw_circle(eye, cr * 0.34, Color("101018"))
	ci.draw_circle(eye + face * cr * 0.1, cr * 0.15, ring)
	ci.draw_circle(eye + face * cr * 0.1 + Vector2(-0.3, -0.3) * cr * 0.12, cr * 0.05, Color.WHITE)
	if flash > 0.0:
		ci.draw_circle(Vector2.ZERO, cr, Color(1, 1, 1, flash))
