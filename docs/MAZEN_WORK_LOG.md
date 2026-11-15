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
