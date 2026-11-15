# ROBOT METABOLISM: Haven Hack Club game jam (Godot 4.3+)

Eat parts. Grow. Become the biggest bot.

## Run it
1. Open Godot 4.3 or newer, click **Import**, and select `project.godot` in this folder.
2. Press **F5**.

## Controls
- WASD, arrow keys, or hold the left mouse button to move.
- Touch loose parts to bolt them onto your robot.
- A **green ring** means you can eat that robot. A **red ring** means it will knock parts off you.
- If you get hit with zero parts left, you're scrapped and it's game over.

## Parts
| Part | Effect |
|---|---|
| WHEEL | Faster movement |
| CLAW | +1 power each, so you can eat bigger robots |
| MAGNET | Pulls scrap from further away |
| CANNON | Auto-shoots the nearest robot. Destroyed robots drop their parts. |

## Files
| File | What it does |
|---|---|
| `scripts/main.gd` | Game manager: spawning, collisions, score, UI, sound, screen shake. **THEME KNOBS are at the top.** |
| `scripts/player.gd` | Player movement, stats, and cannons |
| `scripts/enemy.gd` | Enemy AI: prey flees, hunters chase, hunters with cannons shoot back |
| `scripts/scrap.gd` | Loose parts on the floor |
| `scripts/parts_db.gd` | The list of part types. Add a part here. |
| `scripts/robot_draw.gd` | Draws every robot and part in code, so there are no image files |
| `sfx/` | Sound effects and music (synthesized with a Python script) |

## Rules for working together (to avoid merge conflicts)
- Use one GitHub repo. Each person (and each Codex) works on their **own branch** for **one feature**.
- Put new features in **new files** where possible. Add only small hook lines to `main.gd`.
- Test with F5 before you merge. Abdullah merges.
- Export to Web and upload to itch.io **early**, then again every 2 hours.

## Web export (do this in the first hour!)
1. Go to Editor → Manage Export Templates → Download.
2. Go to Project → Export → Add → Web, then Export Project to `build/index.html`.
3. Zip the `build` folder and upload it to itch.io as an HTML5 game. Tick "SharedArrayBuffer support".
