# Agent brief: MAZEN (Menus, UI & Game Feel)

You're Mazen's coding agent. Mazen owns **everything around the gameplay**: menus, screens, stats, and how good it *feels*.
Read `/AGENTS.md` first (hard rules + progress report). Branch name: `mazen/ui-feel`.

## Your goal
Make the game feel finished and Hollow Knight-like: a moody title screen, a win screen that celebrates deaths, and effects that make every bounce and pogo satisfying.

## What already exists (don't rebuild it)
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
2. **Title screen:** `scenes/menu.tscn` with a big "BOUNCE BACK" title, the subtitle "Every death gets you higher.", Play and Quit buttons, a controls hint (Move A/D · Jump Space · Strike J · Pogo S+J · Dash K), and music. Set it as `run/main_scene`. Play loads `scenes/level_1.tscn` (fall back to `scenes/game.tscn` if it's missing).
3. **Win screen:** `scenes/win.tscn` with "YOU BOUNCED BACK!", total deaths, total geo, total time, the line "Every death got you higher.", and a Play Again button.
4. **Game feel** (new scripts only):
   - A "BOING!" popup Label plus a dust puff (CPUParticles2D) on body bounces, and a small white spark on pogo.
   - A fade-to-black transition between scenes (`SceneTransition` autoload: ColorRect + AnimationPlayer).
   - A short screen flash (white ColorRect, 0.05 s) when a mask is lost (watch `masks` go down).
5. **Pause menu:** Esc pauses (`get_tree().paused`) with Resume / Restart level / Main menu.

## Done when
The game starts on the menu and flows Menu → Levels → Win → Menu, every screen uses the pixel font, and the effects work without editing the protected scripts.
