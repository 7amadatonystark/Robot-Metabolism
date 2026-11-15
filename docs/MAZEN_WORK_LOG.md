# Mazen work log — 2026-11-15

## Scope and decisions
Read AGENTS.md and agents/MAZEN.md. Latest main cloned and pulled before creating
mazen/ui-feel-2. Complete four tasks in order; never edit protected gameplay scripts.
The title/stats work is already merged and will not be rebuilt. Use existing pixel font
and runtime Godot controls/particles, with no generated image/audio assets.

Implementation plan: superpowers/plans/2026-11-15-mazen-ui.md.

Environment: installed Godot is 4.6.3; code targets 4.3 APIs. Native 4.3 and physical PS4
hardware validation remain human checks. GitHub connector returned Unknown tool for
file reads; fallback clone worked. gh reports no signed-in account. PR publication will
be attempted after validated commits; never push main.

## Task 1 — story intro
Planned: black background, one Levels.STORY line at a time; reveal/advance with a fresh
key or CROSS press, ignore key echo; start story level 1 after the final line.

Validation: test_intro first failed because the scene was absent, then printed
RESULT: PASS after implementation. Existing bounce/HK/hazard/stats/parry tests printed
PASS on baseline. test_raid printed FAIL on untouched main: its fixed physics frame 10
reads gm.players before the process-frame-awaited initialization has completed in
headless runs; array indexing then errors. Pacing with --max-fps 60 also reproduces it.
Do not claim raid regression green. Existing protected city_backdrop also reports invalid
polygon data in paced rendering; story-level coins report missing %GameManager on spawn.
These need the gameplay owner's review, not changes to protected files here.

Manual: F5 → Play → choose fighter → fresh keys/CROSS reveal then advance each line;
ignore held keys; final press starts The Docks. Physical controller and 4.3 remain unverified.

## Task 2 — pause menu
New ALWAYS-processing PauseMenu autoload. Escape/OPTIONS only opens in game.tscn,
story_level.tscn, boss_arena.tscn. Standard focused buttons support keyboard, mouse,
and Godot ui_* controller actions; CIRCLE/Escape/OPTIONS resumes. Restart and fighter
change unpause first, and scene identity tracking clears stale pause state.
Test first printed FAIL (autoload missing), then PASS after implementation. Synthetic
Input.parse_input_event needs flush_buffered_events in this headless environment;
adding the flush made the test exercise the events immediately instead of next frame.
Human: Escape/OPTIONS in a level or raid, navigate with arrows/d-pad/stick, CROSS/Enter
Resume/Restart/Change Fighter; check game resumes and select/lobby never pauses.

Publication blocker: automatic approval review rejected git push to origin because it
considered export of potentially private code to this GitHub remote not explicitly
authorized. No retry or alternative upload will be attempted without explicit approval.
Local commits, per-task PR drafts and final patch bundle will remain available for review.

## Task 3 — game feel extras
GameFeel observes each player's masks and launch velocity after player physics. Body
launches show BOING and CPUParticles2D dust; downward slash launches show white sparks;
mask decreases flash white for 0.05 s. Effects are children of the current world scene,
expire automatically, and don't alter movement/damage. Spawn/heals do not flash.
SceneTransition observes outgoing tree_exiting and incoming scene identity. Because
protected scene callers cannot be changed or delayed, the black dip covers the swap
and fades in the new scene; it does not hold the outgoing scene for a full pre-swap fade.
The overlay always processes, never takes mouse focus, and restarts on rapid swaps.
Human: bounce on a body, pogo a hamster, take damage as either raid player, then change
fighter/restart and watch the short black dip. No new image/audio assets were created.

## Task 4 — controls card
CONTROLS button opens an in-pause table with keyboard/PS4 movement, jump, directional
strike/pogo, dash, special, power shot, pause and confirm/back. Back/CIRCLE/Escape
returns focus to CONTROLS; OPTIONS resumes directly from the card.
A synthetic CROSS test exposed that this runtime's built-in ui_accept only contained
keyboard events. Added duplicate-safe explicit CROSS/d-pad/left-stick ui_* bindings,
instead of relying on export defaults. Test now covers actual CROSS activation and
d-pad focus movement as well as card back behavior.

## Test timing finding
--fixed-fps 60 makes the existing raid test pass: fixed physics-frame assertions otherwise
run before the awaited process frame that fills gm.players. --max-fps is insufficient
because the initial scene build can queue several physics ticks before that frame.
Final regression run will use --fixed-fps 60 and still report all baseline diagnostics.

## Review fixes
- D-pad regression initially failed before layout established geometric focus. Explicit
  cyclic focus neighbors make all four buttons navigable immediately. PASS after fix.
- Independent review reproduced restart/change fighter during death slow-motion leaving
  Engine.time_scale=0.5: unloading cancels the manager coroutine before its restore.
  Added real player_died regression for both actions: observed FAIL, then restored
  Engine.time_scale=1.0 in owned scene-change handlers and observed PASS. No protected
  gameplay edits were needed.

- Review also corrected the observer's callback ordering property to
  process_physics_priority=100; process_priority affects idle processing only.
  This keeps bounce observation after the player's movement in the same physics tick.
  Final suite rerun follows this correction.
- Reviewer measured controls card at 625×359 (fits 640×360) and confirmed external
  paused scene changes release pause, and rapid scene swaps end with alpha 0.

## Final human checklist
1. Godot 4.3: import project.godot and F5. Title → Play → fighter → intro → The Docks.
2. Intro: tap any key/CROSS once to reveal and again to advance; holding a key cannot
   skip lines. Complete Level 1 → 2 → 3 → boss → ending (gameplay flow is unchanged).
3. In each level and solo/co-op boss: Escape/OPTIONS, move focus using arrows/d-pad/
   left stick, confirm with Enter/CROSS, click buttons with mouse. Resume, restart,
   change fighter, open controls, return with CIRCLE/Escape, resume with OPTIONS.
4. Die and immediately pause/restart or change fighter: the new scene runs at normal
   speed. Menu/select/lobby/intro should never open the pause overlay.
5. Land on a body → BOING/dust. Down-slash a hamster/spike → white spark. Lose a mask
   as any raid fighter → brief white flash. Restart/scene change → black dip clears.
6. Export Web using existing preset, load on itch.io and repeat menu/pad checks.

## Remaining limits and ownership
- Installed/tested engine: Godot 4.6.3; Godot 4.3, actual PS4 hardware, rendering
  appearance and browser export are not validated in this headless runtime.
- Existing story coin.gd resolves %GameManager without a matching owner in dynamically
  created story coins. Story startup logs node-not-found errors. Abdullah should inspect
  scene ownership in protected story_level.gd; this work does not change those files.
- Existing vice_layer.gd anchor warnings, city_backdrop polygon diagnostics during
  paced rendering, and test shutdown resource warnings are preserved, not hidden.
- Scene fade limitation described in Task 3 is intentional to respect protected scripts.
- Publishing requires explicit authorization after the automatic review rejection, plus
  working GitHub authentication. No push to main and no merges have been attempted.

## Final verification
All nine tests (bounce, hk, raid, hazard_respawn, stats, parry, intro, pause, feel)
print RESULT: PASS, exit 0, with no SCRIPT ERROR using --fixed-fps 60. Final editor
import and main-scene smoke exit 0, no script errors. See validation/mazen-tests.txt.
Independent review findings addressed; git diff --check passes. Protected file audit
shows no changes to any file in AGENTS.md's protected list. Four per-task commits and
local branch checkpoints retained; PR descriptions in docs/pull-requests/.

## Publication follow-up
User explicitly approved branch publication and PR creation. GitHub browser sign-in
was reported complete, but CLI device authorization could not finish because access
to api.github.com was blocked by workspace network policy. gh auth status confirms
no authenticated account. Authorized git push was attempted again with interactive
credential prompts disabled: it failed with "could not read Username". No branch was
uploaded and no PR created. Approval remains granted; only working workspace GitHub
authentication is missing. Do not request publication approval again.
