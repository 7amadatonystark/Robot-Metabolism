# Agent brief: ZIKO (Level Designer)

You're Ziko's coding agent. Ziko owns **the levels**: where the fun and the theme happen.
Read `/AGENTS.md` first (hard rules + progress report). Branch name: `ziko/levels`.

## Your goal
Make 3 short levels where the player **must die on purpose** to progress, because their body becomes a trampoline.
A judge should understand "dying helps me bounce back" within 30 seconds of Level 1.

## Mechanics you design around (Hollow Knight style; see /AGENTS.md)
- Down-slash in the air on an enemy/spike = **pogo** bounce (≈ one normal jump high). You can chain pogos across a row of spikes or slimes.
- Dash (1 air dash) crosses gaps of ~3–4 tiles.
- Death leaves a body with your geo. It's a big bounce pad (≈ 4–5 tiles). Dying now takes 5 hits, so bodies are **rare and precious**. Put **benches** before hard parts.

## Facts you need
- Template level: `scenes/game.tscn` (GameManager + ScoreLabel, TileMap, Player with Camera2D, Killzone, Coins, Platforms, Slime).
- Bottom pit: `Killzone` with `leaves_body = false`. Slimes (`scenes/slime.tscn`) contain a killzone that **does** leave a body.
- Bench (checkpoint + heal): drag in `scenes/checkpoint.tscn`.
- Spikes/hazards: an Area2D with `scripts/killzone.gd` (plus a Timer child, like `scenes/killzone.tscn`) and `leaves_body = false`. For the sprite, use a CC0 spike tile from Kenney "Pixel Platformer" (credit it in README).
- Normal jump ≈ 2 tiles high. Bounce on a body ≈ 4–5 tiles. Hold jump while bouncing ≈ 5–6 tiles. (Tile = 16 px.)
- Don't put a checkpoint right where the player dies (they'd respawn on the body and bounce instantly).

## Tasks (do in order, one at a time; report after each)
0. **Pogo gallery:** in Level 1, after the wall, add a short row of 3 slimes over a pit that you cross only by pogo-chaining (sign: "Strike down. Bounce back.").
1. **Level 1, "First Fall" (tutorial).** `scenes/level_1.tscn`: flat start, a wall ~4 tiles high with a slime patrolling in front of it. In-world labels (like Brackeys' Labels node): "Can't jump this?" → "Try dying." → "Bounce Back!" One coin on top.
2. **Goal + level flow.** `scenes/goal.tscn`: an Area2D (use `assets/sprites/fruit.png` or a coin sprite) that loads the next level when the player touches it (`get_tree().change_scene_to_file(...)`). Use an `@export var next_level: String`.
3. **Level 2, "Stack Up".** Two bounce puzzles, one checkpoint between them, and a moving platform (`scenes/platform.tscn`).
4. **Level 3, "The Tower".** A vertical climb that needs **2+ bodies** stacked at different heights (slimes placed at different heights). Coins reward risky routes.
5. **Polish pass.** Make sure all 3 levels can be finished. Count the minimum deaths for each and write them in your report.

## Done when
All 3 levels are playable start to finish, each goal loads the next level, and level 3's goal loads `scenes/win.tscn` (Mazen makes that; if it doesn't exist yet, load `scenes/level_1.tscn` for now).
