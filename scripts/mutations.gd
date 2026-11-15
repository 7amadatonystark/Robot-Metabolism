# MUTATIONS: at size milestones you pick 1 of 3. Add a new one = one line here + its effect.
extends RefCounted

const MILESTONES := [10, 25, 50, 90, 150, 220]
const MEGABOT_SIZE := 400

const LIST := [
	{"id": "OVERCLOCK", "name": "OVERCLOCK", "desc": "Dash recharges\n2x faster", "color": "4fc3f7"},
	{"id": "SPIKES", "name": "SPIKED HULL", "desc": "Hunters that hit you\nlose 3 parts", "color": "ff8a65"},
	{"id": "TWIN", "name": "TRIPLE BARREL", "desc": "Every cannon shot\nfires 3 bullets", "color": "e57373"},
	{"id": "GRAVITY", "name": "GRAVITY CORE", "desc": "Magnet range\nx2", "color": "ba68c8"},
	{"id": "PRINTER", "name": "SCRAP PRINTER", "desc": "Build a free part\nevery 4 seconds", "color": "81c784"},
	{"id": "APPETITE", "name": "BIG APPETITE", "desc": "Absorb 2x more parts\nwhen you eat", "color": "69f0ae"},
	{"id": "ARMOR", "name": "ARMOR PLATING", "desc": "Lose half the parts\nwhen hit", "color": "b0bec5"},
	{"id": "FEAST", "name": "JAWS", "desc": "+25% power:\neat bigger bots", "color": "ffb74d"},
]


static func pick_three(taken: Dictionary) -> Array:
	var pool := []
	for m in LIST:
		if not taken.has(m.id):
			pool.append(m)
	pool.shuffle()
	return pool.slice(0, mini(3, pool.size()))
