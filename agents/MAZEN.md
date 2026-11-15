# Agent brief: MAZEN (Menus, UI & Game Feel)

You're Mazen's coding agent. Mazen owns **everything around the gameplay**: menus, screens, stats, and how good it *feels*.
Read `/AGENTS.md` first (hard rules + progress report). Branch name: `mazen/ui-feel`.

## Your goal
Make the game feel finished and Hollow Knight-like: a moody title screen, a win screen that celebrates deaths, and effects that make every bounce and pogo satisfying.

## What already exists (don't rebuild it)
- **CHOOSE YOUR FIGHTER screen** (`scenes/character_select.tscn`) is the main scene. It already has the title, the 3 fighters, music and the B = boss shortcut.
- GTA-parody layer (`vice_layer.gd`): BOUNCED death screen, MISSION PASSED, SLIME ALERT stars, sunset tint.
- Boss fight + ending (`boss_arena.tscn`).
- In-game HUD (masks, GEO, deaths) in `game_manager.gd`.
- Camera shake on hits and deaths, slow-mo on death, slash arc, squash-and-stretch on bounce.

## Facts you need
- Font: `assets/fonts/PixelOperator8-Bold.ttf`. Music: `scenes/music.tscn`. Sounds in `assets/sounds/`.
- Game manager (group `"game_manager"`): `deaths`, `score` (= geo), `masks`, `MAX_MASKS`.
- Player (group `"player"`): `velocity`, `is_on_floor()`, `invuln`. Bodies: group `"bounce_pad"`.
- Detect a **body bounce**: player `velocity.y` ≤ -400 right after landing. Detect a **pogo**: `velocity.y` suddenly ≈ -300 while in the air.
- Style: Hollow Knight menus. Dark background, white pixel text, simple centered layout, slow fades.
- You can't edit the protected scripts, so react from **your own** scripts (watch values change each frame).

## Tasks (do in order, one at a time; report after each)
1. **Stats autoload:** `scripts/stats.gd`, registered as autoload `Stats` in `project.godot`: `total_deaths`, `total_geo`, `start_time`. A small node script added to each level copies the game manager's `deaths` and `score` into `Stats` before the scene changes.
2. **Title screen** (optional, before the fighter select): `scenes/menu.tscn` with "VICE SLIME", "Press any key", a controls hint (Move A/D · Jump Space · Strike J · Pogo S+J · Dash K), and the Brackeys music. Any key → `scenes/character_select.tscn`. Only if it's done, set it as `run/main_scene`.
3. **Win screen:** `scenes/win.tscn` with "YOU BOUNCED BACK!", the fighter you played (`Engine.get_meta("character")`), total deaths, total geo, total time, the line "Every death got you higher.", and a Play Again button that goes to `scenes/character_select.tscn`. (The boss ending can link to it later; Abdullah wires that.)
4. **Game feel** (new scripts only):
   - A "BOING!" popup Label plus a dust puff (CPUParticles2D) on body bounces, and a small white spark on pogo.
   - A fade-to-black transition between scenes (`SceneTransition` autoload: ColorRect + AnimationPlayer).
   - A short screen flash (white ColorRect, 0.05 s) when a mask is lost (watch `masks` go down).
5. **Pause menu:** Esc pauses (`get_tree().paused`) with Resume / Restart level / Change fighter (→ `scenes/character_select.tscn`).

## Done when
The game starts on the menu and flows Menu → Levels → Win → Menu, every screen uses the pixel font, and the effects work without editing the protected scripts.
