# Agent brief: MAZEN (Menus, UI & Game Feel)

You're Mazen's coding agent. Mazen owns **everything around the gameplay**: menus, screens, stats, and how good it *feels*.
Read `/AGENTS.md` first (hard rules + progress report). Branch name: `mazen/ui-feel`.

## Your goal
Make the game feel finished and juicy: a title screen, a win screen that celebrates deaths, and effects that make every bounce satisfying.

## Facts you need
- Font: `assets/fonts/PixelOperator8-Bold.ttf`. Music: `scenes/music.tscn`. Sounds in `assets/sounds/`.
- Player group `"player"`, bodies group `"bounce_pad"`, game manager group `"game_manager"` (`deaths` variable).
- You can't edit the protected scripts, so react to events from **your own** scripts (e.g. watch `game_manager.deaths` change, or check the player's velocity and floor contact).

## Tasks (do in order, one at a time; report after each)
1. **Stats autoload.** `scripts/stats.gd` registered as autoload `Stats` (in `project.godot`): `total_deaths`, `start_time`. Add a small node script that copies the level's death count into `Stats.total_deaths` when a level changes.
2. **Title screen.** `scenes/menu.tscn`: big "BOUNCE BACK" title, subtitle "Every death gets you higher.", Play and Quit buttons, music playing. Set it as `run/main_scene`. Play loads `scenes/level_1.tscn` (Ziko makes it; fall back to `scenes/game.tscn` if it's missing).
3. **Win screen.** `scenes/win.tscn`: "YOU BOUNCED BACK!", total deaths, total time, the line "Every death got you higher.", and a Play Again button.
4. **Game feel** (new scripts only):
   - Camera shake when deaths increase (shake the player's Camera2D for 0.2 s).
   - A "BOING!" popup label plus a dust puff (CPUParticles2D) when the player bounces on a `bounce_pad` (detect: player velocity.y suddenly ≤ -400).
   - A fade-to-black transition between scenes (a `SceneTransition` autoload with a ColorRect + AnimationPlayer).
5. **Pause menu.** Esc pauses (`get_tree().paused`) with Resume / Restart level / Main menu.

## Done when
The game starts on the menu, flows Menu → Levels → Win → Menu, all screens use the pixel font, and the bounce effects work without editing the protected scripts.
