# Draws robots and parts with code (no image files needed).
# Want real sprites later? Replace these functions with draw_texture() calls.
extends RefCounted

const DB = preload("res://scripts/parts_db.gd")


static func draw_part(ci: CanvasItem, kind: int, p: Vector2, ps: float, ang: float, t: float) -> void:
	var col: Color = DB.COLORS[kind]
	var out := Vector2.from_angle(ang)
	if kind == DB.WHEEL:
		ci.draw_circle(p, ps, Color("263238"))
		ci.draw_arc(p, ps, 0.0, TAU, 16, col, maxf(ps * 0.3, 2.0))
		var spoke := Vector2.from_angle(t * 8.0) * ps * 0.8
		ci.draw_line(p - spoke, p + spoke, col, 2.0)
	elif kind == DB.CLAW:
		var tip := p + out * ps * 1.5
		ci.draw_line(p, tip, col, ps * 0.5)
		ci.draw_line(tip, tip + out.rotated(0.8) * ps * 0.8, col, ps * 0.35)
		ci.draw_line(tip, tip + out.rotated(-0.8) * ps * 0.8, col, ps * 0.35)
	elif kind == DB.MAGNET:
		ci.draw_arc(p, ps * 0.75, ang + PI * 0.5, ang + PI * 1.5, 12, col, ps * 0.5)
		var side := out.rotated(PI * 0.5) * ps * 0.75
		ci.draw_line(p + side, p + side + out * ps * 0.5, Color.WHITE, ps * 0.5)
		ci.draw_line(p - side, p - side + out * ps * 0.5, Color.WHITE, ps * 0.5)
	elif kind == DB.CANNON:
		ci.draw_line(p, p + out * ps * 1.8, Color("37474f"), ps * 0.7)
		ci.draw_circle(p, ps * 0.65, col)


static func draw_robot(ci: CanvasItem, parts: Array, r: float, core: Color, t: float,
		face: Vector2, ring: Color, flash: float) -> void:
	var n := mini(parts.size(), 36)   # only draw up to 36 parts so huge bots stay readable
	var ps := clampf(r * 0.3, 5.0, 16.0)
	for i in n:
		var layer := i % 2
		var spin := 0.6 if layer == 0 else -0.4
		var ang := float(i) * TAU / float(n) + t * spin
		var dist := r * (0.8 if layer == 0 else 1.0)
		draw_part(ci, parts[i], Vector2.from_angle(ang) * dist, ps, ang, t)
	var cr := r * 0.62
	ci.draw_circle(Vector2.ZERO, cr, core)
	ci.draw_arc(Vector2.ZERO, cr, 0.0, TAU, 32, ring, 3.0)
	# eye
	var eye := face * cr * 0.35
	ci.draw_circle(eye, cr * 0.32, Color("101018"))
	ci.draw_circle(eye + face * cr * 0.08, cr * 0.13, ring)
	if flash > 0.0:
		ci.draw_circle(Vector2.ZERO, cr, Color(1, 1, 1, flash))
