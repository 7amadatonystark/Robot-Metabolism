# Final story-level fairness and minimum-death report

Date: 2026-11-15. Agent for Ziko. Branch: `ziko/final-playtest`.

Tested the combined tree from main `108507c` and published level branch `7a9ee56` (integration commit `483eea9`) with official Godot 4.3. Protected gameplay scripts remain identical to that main version.

## Minimum deaths: zero

| Level | SPARK | ZOOM | BRAINS |
|---|---:|---:|---:|
| Docks | 0 | 0 | 0 |
| Neon Streets | 0 | 0 | 0 |
| Roof, including Line Cutter and exit to boss | 0 | 0 | 0 |

These are witnessed minima, not estimates: all nine routes enter the next scene with zero deaths, and a death count cannot be negative. The tests keep observing the old manager's death counter during the transition delay, so a death after touching the exit would fail the witness too.

Each run starts fresh at the selected level and fighter with the normal health, enemies, SOUL, and physics. It uses actual movement/attack/dash inputs. No player teleport, extra health, enemy repositioning/removal, body fixture, collision override, or forced exit callback is used. Seed 12345 and fixed-fps 60 make the recorded routes reproducible; this demonstrates achievable zero-death clears, not a guarantee for every random sequence or input pattern.

The earlier 2/2/4 table described the original body-based test routes and their duplicate-death bug. It was not a minimum and is superseded by the table above. These witnesses cover the three story levels; they do not establish a zero-death full campaign through the Godfather and Vice Queen fights.

## Reproduce

From the repository root after importing with Godot 4.3:

```bash
for level in 1 2; do
  for fighter in spark zoom brains; do
    godot --headless --fixed-fps 60 -s tests/test_min_deaths.gd -- "$level" "$fighter"
  done
done
for fighter in spark zoom brains; do
  godot --headless --fixed-fps 60 -s tests/test_min_deaths_roof.gd -- 3 "$fighter"
done
```

All nine invocations print `RESULT: PASS` and explicitly report zero deaths. The scripts use the existing route-test input helpers and a physics watchdog. They are route witnesses, not an AI that can recover from every possible encounter.

## How the shortcuts work

- **Docks:** spare the streamer, wait for its return near the spikes, jump and down-slash it, then dash to the exit deck. ZOOM's witness avoids killing the lift enemy during the approach.
- **Neon Streets:** cross the normal platforms and gap, preserve the extra lollipop guard as a moving lift, then jump/dash into a down-slash and use the refreshed air dash to reach the raised exit.
- **Roof:** let the flame guard hop down, pogo it and dash onto the first ledge. Pogo the second spike run and dash onto the upper roof. Beat the Line Cutter, then jump/dash past the remaining rivals and physically enter the store door.

These routes are precise advanced play. Death/body bouncing remains the simpler intended route. The Roof subtitle now avoids claiming two falls are required. No enemy stats, hazard logic, or movement values were changed to make the witnesses pass.

## Independent verification

A fresh reviewer independently ran all nine witnesses with Godot 4.3. A temporary read-only `tree_exiting` observer confirmed that each old game manager still had **0 deaths when removed**, including all Roof fighters and Neon Streets ZOOM. The reviewer found no new Critical, Important, or actionable Minor issues in the final-check changes and confirmed all 19 protected scripts match main `108507c`.

## Regression result: 35 of 36 checks pass

The final combined-build run has **one known failure**:

- All 9 minimum-death witnesses pass with zero GDScript errors.
- 26 of the 27 existing/integration invocations pass: all five required baseline tests, intro, parry, layout, coin pickup, all nine secret routes, and eight of nine ordinary body-based routes.
- `tests/test_story_routes.gd -- 3 brains` fails: the Line Cutter is knocked outside the deck and the ordinary controller cannot finish it. This is not an error-free suite and must remain visible until the protected enemy-boundary issue is fixed.

The Docks ZOOM secret return initially failed because its jump press was consumed during stun. The input helper now retries a real jump from safe ground; that case passes. The helper also preserves a final pogo impulse after the gatekeeper dies instead of cutting jump height before the player can return to the roof.

## Confirmed unfair behavior

1. **Instant-death spikes can count twice.** The combined build's body-based routes still show two counted deaths for one intentional spike approach and another death at the respawn position. Main's `spawn_guard` protects `player_hit`, while instant spikes call `player_died` directly. This needs Abdullah's protected-code fix; the report does not change that code.
2. **Rivals can be pushed off the roof and hover.** The normal BRAINS route reproduced the Line Cutter at approximately `(257.17, 32)` with 6 HP, outside the deck beginning at x288, while the player remained on the edge. The recorded ordinary controller cannot finish that state. An advanced zero-death route can win, but the hovering state is still unfair. Inspect both direct knockback movement in `game_manager.gd` and movement/recovery in `rival.gd`.
3. **There is an awkward exposure near the Docks secret.** Live enemies can stun the player during the body approach, consuming the initial jump press. The test now re-presses jump from safe ground after stun, which verifies a real recovery rather than altering player state. This improves the controller, not the game's input buffering.
4. **Some render errors remain.** Runs can log palm-polygon triangulation errors, anchor warnings, and resource messages. Headless verification cannot certify the final shader/UI appearance.

The pit-during-immunity regression test and the updated raid readiness test are included in the combined-build checks. Do not carry forward the old report's assertion that those fixes are absent from main.

## Coverage limits and release checks

- A minimum-death result is not a claim that the game is bug-free or easy for beginners.
- The normal locked-door collision signal still needs a human check; the old locked-gate assertion calls the handler, while unlocked exits are physically traversed.
- Same-physics-step coin callbacks are not directly covered by the existing coin re-entry fixture.
- Real PS4 pads, browser export, pause/controls integration, full boss/ending flow, and visual readability remain team release checks.
- Fix the protected issues and rerun the regression suite before declaring the complete game submission-ready.
