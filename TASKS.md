# TASKS

## Each teammate's agent has a brief
- Ziko → `agents/ZIKO.md` (levels)
- Mazen → `agents/MAZEN.md` (menus, UI, game feel)
- Shared rules + required progress report → `AGENTS.md`

First message to Codex: **"I'm Ziko. Read AGENTS.md and agents/ZIKO.md, then do Task 1."** (or Mazen)

## Old quick prompts (Ziko, one at a time, on your own branch)

**Start every prompt with:** "Godot 4.3, this repo. Don't edit scripts/player.gd, scripts/game_manager.gd, scripts/body_pad.gd or scripts/killzone.gd."

1. **LEVELS:** "Create 3 levels as scenes/level_1.tscn, level_2.tscn, level_3.tscn, copying the structure of scenes/game.tscn (GameManager with ScoreLabel, TileMap with the same tileset, Player with Camera2D, a bottom Killzone with leaves_body = false). Level 1 teaches the mechanic: a wall too high to jump, with a slime right in front of it, so dying there leaves a body you can bounce on to get over. Level 2: two bounce puzzles plus a checkpoint (scenes/checkpoint.tscn). Level 3: a vertical tower you climb by stacking deaths. Put a scenes/goal.tscn (Area2D) at the end of each level that loads the next level; the last one loads scenes/win.tscn."
2. **MENUS:** "Make scenes/menu.tscn (title 'BOUNCE BACK', Play and Quit buttons, using assets/fonts/PixelOperator8-Bold.ttf) and set it as the main scene. Make scenes/win.tscn that shows total deaths with the line 'Every death got you higher.' and a Play Again button. Store total deaths in an autoload called Stats."
3. **GAME FEEL:** "Add camera shake when the player dies (shake the Camera2D under Player for 0.2 s), a dust particle puff (CPUParticles2D) when the player lands, and a small 'BOING!' Label that pops up when bouncing on a node in group 'bounce_pad'. Use signals or new scripts; don't edit the 4 protected scripts."

## Abdullah (with Claude)
- [x] Bounce-on-body mechanic, death counter, respawn, checkpoints
- [ ] Merge Ziko's branches and playtest
- [ ] Web export to itch.io (Project → Export → Web) and upload early
- [ ] Pitch plus a 30–60 s gameplay video

## Assets (no AI): use only these
- Brackeys Platformer Bundle (already in `assets/`, CC0)
- kenney.nl (CC0): Pixel Platformer, Impact Sounds, Interface Sounds, Music Jingles
- sfxr.me / jsfxr: make your own retro sound effects
- opengameart.org / freesound.org: check each license and credit CC-BY files on the itch page
