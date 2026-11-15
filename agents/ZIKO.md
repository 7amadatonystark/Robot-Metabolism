# Agent brief: ZIKO (Level Designer)

You're Ziko's coding agent. Ziko owns **the levels**: where the fun and the theme happen.
Read `/AGENTS.md` first (hard rules + progress report). Branch name: `ziko/levels`.

## Your goal
Make 3 short levels that teach and combine the two "bounce back" moves:
1. **Pogo:** down-slash off enemies and spikes.
2. **Your own body:** die on purpose (death spikes), then bounce off your body to reach higher.

A judge should understand "dying helps me bounce back" within 60 seconds of Level 1.

## Fighters
Players pick SPARK, ZOOM or BRAINS first (`scenes/character_select.tscn`). All three run at the same speed. SPARK reaches further, ZOOM hits twice as hard, and BRAINS has 6 masks. Make sure every level works for all of them. When you test a level with F6, you play as the Brackeys knight (same speed).

## Numbers (tile = 16 px)
- Normal jump ≈ 2 tiles up. Pogo ≈ 2 tiles up from the hit point (chainable).
- Body bounce ≈ 4–5 tiles (hold jump ≈ 5–6). Dash ≈ 3–4 tiles across (1 air dash).
- The player has 5 masks. Normal damage doesn't kill fast, so use **death spikes** where you want the player to die on purpose.

## Building blocks
- Template level: `scenes/game.tscn` (GameManager + ScoreLabel, TileMap, Player with Camera2D, Killzone, Coins, Platforms, Slime). Copy it for each level.
- **Slime** (`scenes/slime.tscn`): an enemy with 2 HP that you can pogo off.
- **Pit / hazard:** `scenes/killzone.tscn` + a CollisionShape2D, with `leaves_body = false` (costs 1 mask and returns you to the edge).
- **Death spikes:** `scenes/killzone.tscn` + a CollisionShape2D, with **`instant_kill = true`** (instant death; your body stays exactly there). Sprite: CC0 spike tile from Kenney "Pixel Platformer" (Ziko downloads it; credit it in `CREDITS.md`).
- **Bench:** drag in `scenes/checkpoint.tscn` (respawn here + full heal).
- **Signs:** Label nodes in the world, like Brackeys' `Labels` node, with the Brackeys pixel font.

## Tasks (do in order, one at a time; report after each)
1. **Level 1, "First Fall"** (`scenes/level_1.tscn`):
   a. Flat start, sign "J to strike."
   b. One slime over a 3-tile gap: sign "Strike down. Bounce back." (pogo across).
   c. A ledge ~5 tiles high with death spikes under it: sign "Too high? Fall here." Then the player dies, bounces off their own body, and reaches the top.
   d. Bench before (c). Coin on top.
2. **Goal + level flow:** `scenes/goal.tscn`, an Area2D (use `assets/sprites/fruit.png` or a coin sprite) with `@export var next_level: String` that calls `get_tree().change_scene_to_file(next_level)` when the player touches it.
3. **Level 2, "Old Knights":** a pogo chain over 3 slimes or spikes, a dash gap, one body puzzle, a bench between sections, and a moving platform (`scenes/platform.tscn`).
4. **Level 3, "The Tower":** a vertical climb that needs **2+ bodies** at different heights (death spikes on different floors), plus pogo sections. Coins reward risky routes.
5. **Polish pass:** make sure all 3 levels can be finished. Report the minimum deaths per level and anything that felt unfair.

## Done when
All 3 levels can be beaten start to finish, each goal loads the next level, and **level 3's goal loads `scenes/boss_arena.tscn`** (the Slime Kingpin boss, already built).
