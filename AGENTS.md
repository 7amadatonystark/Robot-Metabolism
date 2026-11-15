# AGENTS.md: rules for every AI coding agent (Codex, Claude, etc.)

You're working on **BOUNCE BACK**, a Godot 4.3 (GDScript) 2D platformer for the Haven Hack Club game jam (theme: "Bounce Back").
**Core mechanics (Hollow Knight style):**
- **Nail attack:** J or X. Hold W to slash up; in the air, hold S to slash down.
- **POGO:** a down-slash that hits an enemy, spikes or one of your bodies bounces you up (HK's signature move, and our "Bounce Back").
- **Dash:** K, C or Shift (one air dash, refreshed on landing or after a pogo).
- **Masks:** 5 health. Enemies = knockback, -1 mask. Hazards (spikes/pits) = -1 mask and respawn at the last safe ground.
- **Geo:** coins. Enemies drop 2 geo.
- **Benches:** checkpoint + full heal.
- **THE TWIST (our Shade):** at 0 masks you die. Your body stays where you fell, holding all your geo, and it becomes a **bounce pad**. Strike your body to take the geo back; land on it to bounce much higher.

## Who are you working for?
- If the human is **Ziko** → read and follow `agents/ZIKO.md`
- If the human is **Mazen** → read and follow `agents/MAZEN.md`
- If you don't know, ask: "Are you Ziko or Mazen?" before changing anything.

## Hard rules (all agents)
1. **Protected files: DO NOT EDIT** `scripts/player.gd`, `scripts/game_manager.gd`, `scripts/body_pad.gd`, `scripts/killzone.gd`. Abdullah owns them. If you need a change there, say so in your report instead.
2. Work on **your own branch** (`ziko/...` or `mazen/...`). Never push to `main`. Open a pull request when a task works.
3. Godot **4.3**, GDScript, renderer = GL Compatibility (must run in the browser on itch.io).
4. **No AI-generated assets** (images, music, sounds). Use only `assets/` (Brackeys bundle, CC0) or CC0 packs from kenney.nl that the human downloads. Credit any new asset in `README.md`.
5. Keep changes small. Prefer **new scripts and scenes** over editing existing ones.
6. Useful hooks: the player is in group `"player"` (`facing`, `invuln`, `last_safe`, `take_hit()`), bodies are in group `"bounce_pad"` (`geo`), and the game manager is in group `"game_manager"` (`masks`, `MAX_MASKS`, `score` = geo, `deaths`, `respawn_point`, `player_hit(from_pos, hazard)`, `player_died()`, `set_checkpoint(pos)`, `hit_enemy(enemy, by)`). Enemies = any node with a `Killzone` child (killzone `leaves_body = true`); hazards = a killzone with `leaves_body = false`. Enemy HP is stored as meta `"hp"` (default 2).
7. After changes, the game must still open and run (F5). If you can run Godot headless, run `godot --headless -s tests/test_bounce.gd` and `godot --headless -s tests/test_hk.gd`. Both must print `RESULT: PASS`.

## Required: progress report at the end of EVERY response
Finish every response with this block filled in:

```
## PROGRESS REPORT
Agent for: <Ziko|Mazen>
Branch: <branch name>
Task: <task number + name from your agents/ file>
Status: <DONE | IN PROGRESS | BLOCKED>
Done this session:
- <file changed/created>: <what it does>
How to test (human): <exact steps, e.g. "Open scenes/level_1.tscn, press F6, walk right into the slime">
Problems / needs Abdullah: <anything blocked, or "none">
Next task: <what you'll do next>
```
