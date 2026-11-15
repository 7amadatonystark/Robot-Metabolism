# BOUNCE BACK: Haven Hack Club game jam (Godot 4.3+)

**Theme: Bounce Back.** A Hollow Knight-style platformer: strike down to **pogo** off enemies and spikes.
When you die, your body stays behind holding your geo, as a **bounce pad**. Your failures help you bounce back higher.

Built on Brackeys' "How to make a Video Game - Godot Beginner Tutorial"
(YouTube: https://www.youtube.com/watch?v=LOhfqjmasi0, code: https://github.com/Brackeys/first-game-in-godot, public domain).
Assets: Brackeys Platformer Bundle (CC0): https://brackeysgames.itch.io/brackeys-platformer-bundle. See `CREDITS.md`.

## Run
Open Godot 4.3+, click **Import**, select `project.godot`, then press **F5**.

### Controls (Hollow Knight style)
| Key | Action |
|---|---|
| A/D or ←/→ | Move |
| Space | Jump (hold = higher, tap = short hop) |
| J or X | Nail attack (hold W = up-slash; in the air hold S = **down-slash / POGO**) |
| K, C or Shift | Dash (1 air dash, refreshed on landing or after a pogo) |

### Systems
- **5 masks** (health). Enemies knock you back and cost 1 mask. Hazards cost 1 mask and send you to the last safe ground.
- **Geo** (coins). Slimes take 2 hits and drop 2 geo.
- **Benches** = checkpoint + full heal.
- **Death spikes** (`instant_kill`): instant death, so your body lands exactly there. Used for "die on purpose" puzzles.
- **Die → your body stays** with all your geo, as a **bounce pad**. Strike it to take your geo back; land on it to bounce high.

## Files
| File | What it does |
|---|---|
| `scripts/player.gd` | Brackeys movement + nail attack, pogo, dash, knockback, bouncing on bodies |
| `scripts/game_manager.gd` | Masks, geo, deaths, benches, hazard respawn, enemy HP, leaving bodies, HUD |
| `scripts/body_pad.gd` | Your body: solid, bouncy, holds your geo (glowing dot) |
| `scripts/killzone.gd` | Damage area. `leaves_body` on = enemy; off = hazard. `instant_kill` = death spikes |
| `scripts/checkpoint.gd` + `scenes/checkpoint.tscn` | **Bench**: drag into a level (respawn here + heal) |
| `scenes/boss_arena.tscn` + `scripts/boss_arena.gd` | Boss room "The Throne", built from Brackeys tiles (`assets/world_tileset.tres`) |
| `scripts/slime_king.gd` | **Slime Kingpin** boss: hops, slams (jump the shockwave), spawns slimes in phase 2. Only pogo hits hurt him |
| `scripts/ending.gd` | After the boss: MISSION PASSED, then all your old bodies stand up. "They all got back up." |
| `scripts/vice_layer.gd` | GTA VI parody layer: sunset tint, SLIME ALERT stars, BOUNCED death screen, MISSION PASSED, meme title card. Game title constant lives here |
| `tests/test_bounce.gd`, `tests/test_hk.gd` | Automatic tests: `godot --headless -s tests/<file>.gd` should print `RESULT: PASS` |
| `export_presets.cfg` | Web export preset (Project → Export → Web) |

## Level design numbers (tile = 16 px)
| Move | Height / distance |
|---|---|
| Normal jump | ≈ 2 tiles up |
| Pogo off an enemy or spike | ≈ 2 tiles up from the hit point (chainable) |
| Bounce on a body | ≈ 4–5 tiles up (hold jump ≈ 5–6) |
| Dash | ≈ 3–4 tiles across |

## Level design rules
1. Every level needs at least one ledge you can **only** reach by bouncing on your own body. Put **death spikes** (`instant_kill = true`) right below it.
2. Teach pogo before you require it (a single slime over a small gap first).
3. Put a **bench** before every hard part, but never right on a death spot (you'd respawn on your body and bounce instantly).
4. Pits = hazard killzone (`leaves_body = false`): costs 1 mask, puts you back on the edge.

## Team
- **Abdullah + Claude:** core mechanics (protected scripts), merging, web export, pitch.
- **Ziko + Codex:** levels → `agents/ZIKO.md`
- **Mazen + Codex:** menus, UI, game feel → `agents/MAZEN.md`
- Rules for every agent → `AGENTS.md`

The old robot game is saved on the `bounceback-bot` branch.
