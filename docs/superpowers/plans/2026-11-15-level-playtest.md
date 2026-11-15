# Story level playtest implementation plan

Goal: execute Ziko's level brief without changing Abdullah's protected scripts.
Spec: AGENTS.md and agents/ZIKO.md. User authorized starting the documented work.
Architecture: preserve the text-map loader and movement; change map data only where a reproduced issue requires it. Add a headless story test and a concise playtest report.
Tech stack: Godot 4.3, GDScript, GL Compatibility.

## Constraints
- Work on ziko/levels; never push main or edit protected scripts.
- No generated assets or dependency changes.
- Reproduce baseline failures and report protected-code issues separately.

## Steps
- [x] Import with Godot 4.3 and run bounce, HK, and raid baseline tests.
- [x] Exercise story traversal for each fighter, including intentional spike deaths, checkpoints, body bounces, and the final exit gate.
- [x] Correct reproduced map issues; keep changes limited to scripts/levels.gd.
- [x] Run story regression and all three existing tests; inspect the final diff.
- [ ] Document test limits, minimum-death routes, protected-code blockers; commit and open a reviewable PR.

## Review focus
- Body bounce takeoff positions and clearance; no teleported traversal claimed as a full playthrough.
- Checkpoints outside spike zones; enemies on supported ground.
- Line Cutter has room to telegraph and charge; gate remains connected to boss.
- All fighters tested using their actual collision and movement.
- Baseline failures must remain visible in the report, even if unrelated to maps.

## Execution ledger
- Fresh clone of main at 727c1cc; branch ziko/levels.
- Installed engine is 4.6.3; downloaded official Godot 4.3 for required-version verification.
- Baseline on 4.6.3: bounce PASS, HK PASS, raid FAIL (players missing); rerunning on 4.3 before attributing root cause.

- Godot 4.3 baseline: bounce, HK, raid PASS.
- Reproduced unsupported scalper and failed Docks step / rooftop ZOOM routes before map edits.
- Final verification: 9/9 scripted story routes, layout test and all 3 original tests PASS. Coin callback errors remain in all three Level 2 logs; this is not an error-free full-game claim.
- Ruling: map fixes and their tests only; protected coin/hazard ownership and duplicate-death issues are documented for Abdullah rather than changed.
- Ruling: a fresh checkout on ziko/levels isolates the work; no second worktree needed.

- Independent review: no Critical or Important findings; independently reran all 13 invocations with the same results.
- Final: minor (deferred): locked-gate test invokes the handler directly, rather than physically entering the locked door. Unlocked entry and scene transition are exercised physically; document the remaining human check.
- Working branch is ready for a PR; main remains unchanged.
