# BOUNCE BACK: Haven Hack Club game jam (Godot 4.3+)

**Theme: Bounce Back.** Every time you die, your body stays behind as a **bounce pad**.
Use your failures to bounce back higher.

Built on Brackeys' "How to make a Video Game - Godot Beginner Tutorial"
(YouTube: https://www.youtube.com/watch?v=LOhfqjmasi0, code: https://github.com/Brackeys/first-game-in-godot, public domain).
Assets: Brackeys Platformer Bundle (CC0): https://brackeysgames.itch.io/brackeys-platformer-bundle

## Run
Open Godot 4.3+, click **Import**, select `project.godot`, then press **F5**.
Controls: A/D or Left/Right arrows to move, Space to jump. Hold Space while landing on a body to bounce higher.

## How the mechanic works (files)
| File | What it does |
|---|---|
| `scripts/game_manager.gd` | Counts deaths, leaves a body where you died, respawns you at the last checkpoint |
| `scripts/body_pad.gd` | The body: solid, lying down, squishes when you bounce on it |
| `scripts/player.gd` | Brackeys movement plus: bounce when landing on a body, die/respawn, sounds |
| `scripts/killzone.gd` | Touch = die. **`leaves_body`** on = body stays (slimes, spikes); off = bottomless pit |
| `scripts/checkpoint.gd` + `scenes/checkpoint.tscn` | Drag into a level. You respawn here after touching it |
| `tests/test_bounce.gd` | Automatic test: `godot --headless -s tests/test_bounce.gd` should print PASS |

## Level design rules (important!)
1. Every level must have at least one ledge you can **only** reach by dying in the right spot and bouncing on your body.
2. Put killzones (slimes, spikes) **next to** the gap. Dying there = a free trampoline.
3. Don't put a checkpoint right on top of a death spot, or you'll respawn on your own body and bounce instantly.
4. A bounce goes about 2x as high as a normal jump. Holding Space goes about 2.4x as high.

## Team
- **Abdullah + Claude:** mechanic, game manager, merging, web export.
- **Ziko + Codex:** levels, menus, game feel. See `TASKS.md`.

The old robot game is saved on the `bounceback-bot` branch.
