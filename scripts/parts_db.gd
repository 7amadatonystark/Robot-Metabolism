# All the robot part types live here. Add a new part = add one line to each list.
extends RefCounted

const WHEEL := 0   # move faster
const CLAW := 1    # bite bigger robots (each claw = +1 power)
const MAGNET := 2  # pull scrap from further away
const CANNON := 3  # auto-shoots the nearest enemy

const COUNT := 4
const NAMES := ["WHEEL", "CLAW", "MAGNET", "CANNON"]
const PERKS := ["+SPEED", "+BITE", "+PULL", "+GUN"]
const COLORS := [Color("4fc3f7"), Color("ffb74d"), Color("ba68c8"), Color("e57373")]
