# AGENTS.md: rules for every AI coding agent (Codex, Claude, etc.)

You're working on **BOUNCE BACK**, a Godot 4.3 (GDScript) 2D platformer for the Haven Hack Club game jam (theme: "Bounce Back").
**Core mechanic:** when the player dies, their body stays where they died as a bounce pad. The player respawns at the last checkpoint and uses old bodies to bounce higher.

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
6. Useful hooks: the player is in group `"player"`, bodies are in group `"bounce_pad"`, and the game manager is in group `"game_manager"` (it has `deaths`, `respawn_point`, `player_died(leave_body)`, `set_checkpoint(pos)`).
7. After changes, the game must still open and run (F5). If you can run Godot headless, run `godot --headless -s tests/test_bounce.gd` and it must print `RESULT: PASS`.

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
