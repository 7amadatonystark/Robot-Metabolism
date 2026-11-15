# Level secrets implementation plan

Goal: complete Ziko Task 2 with one optional high coin ledge per level.
Spec: agents/ZIKO.md and AGENTS.md. Continue on ziko/levels; keep protected scripts and assets untouched.
Architecture: paired one-way platforms in existing text maps, reached from an existing body pad. Repair the unprotected coin.gd lookup so the rewards work. No new systems or assets.
Tech stack: official Godot 4.3 and GDScript.

## Steps
- [x] Reproduce coin reward failure, then replace the owner-dependent lookup with the existing game_manager group; credit the modification.
- [x] Add a real-input secret-route test before editing maps; confirm each missing ledge fails.
- [x] Add one ledge per level, above ordinary-jump pickup range from adjacent normal terrain, with a safe route back.
- [x] Run secret routes with all fighters, normal routes, layout, coin, bounce, HK, and raid tests; document remaining protected bugs.
- [x] Review, commit, refresh the cumulative patch, and verify it applies to original main.

## Review focus
- Existing exits and bounce gates still work.
- Coin rewards are awarded once and the pickup animation removes the coin.
- Optional ledges do not create a normal-jump shortcut to high rewards.
- Test fixtures that teleport are isolated collision tests and never described as playthroughs.
- Body bounces and secret returns use real inputs; no health or movement overrides.

## Ledger
- Main and instructions remain at 727c1cc; prior level fixes are already committed through bb0a6a0.
- Ruling: coin.gd is not in the protected-file list. Repair this small dependency of meaningful secrets rather than adding unrewarded coins or touching the protected loader.
- GitHub write denial remains; do not repeat publication attempts without changed access.

- Coin collision test: RED (null manager) then GREEN (one reward, no duplicate, removal).
- All three missing secret tests failed before maps were edited. Nine secret routes then passed with real inputs, rewards, and death-free returns.
- All 23 invocations passed, with no GDScript errors.
- Ruling: select the original spike body explicitly for the Docks return; the protected duplicate-death bug creates another body at the bench, which is not the intended takeoff. No production movement or health is overridden.

## Continued work — Tasks 3–5
- [x] Add two supported guards in Neon Streets and a flame guard on the Roof ledge.
- [x] Add rivals across all three levels, keeping the first pit approachable; move the Line Cutter spawn farther from the rooftop entry.
- [x] Verify normal routes, secret routes, reward, layout, and the three required tests on Godot 4.3.
- [x] Update the handoff report with observed deaths and protected-code findings.
- [x] Review, commit, and refresh the cumulative handoff patch.

- First encounter pass failed: intro rival knockback exposed the known pit recovery bug; move new Docks rivals beyond the bench. A crowded rooftop was reduced to streamer/preorder plus the Line Cutter.
- Ruling: do not patch the protected rival movement. Document the off-deck knockback bug; the test controller may use actual dash/pogo inputs to recover, without moving enemies or granting health.
- Added a physics watchdog and failure guards after a failed secret approach otherwise left a coroutine stopped and the game running indefinitely.
- Corrected controller turning to use exclusive directional input, and kept ZOOM's off-deck pogo recovery separate from the other fighters.
- Final serial suite: 23/23 PASS, zero GDScript errors. Concurrent baseline raid timing failure is explicitly documented, not hidden by the final pass.
- Task 5 remains partial: report verified counts 2/2/4 per fighter; do not call them global minima without further route discovery.

- Final independent review: no Critical or Important findings. Reviewer reran the coin fixture, Roof ZOOM route, and all three SPARK secret routes: PASS, no GDScript errors.
- Final: minor (deferred): the re-entry coin test runs after collision is disabled, so it does not directly cover the production collected guard for same-step callbacks. Guard remains correct; document this coverage limit.
- Final: minor (deferred, carried): locked-gate handler is invoked directly, while unlocked exit is physically traversed. Human locked-door collision check remains.
- Cumulative patch verified against original main, with all final files matching. Publication remains blocked by the previously observed GitHub 403; no permission change was observed and no further write attempt was made.
