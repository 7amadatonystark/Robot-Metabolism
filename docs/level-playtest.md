# Ziko — story level playtest

Branch: `ziko/levels`. Based on main `727c1cc`. Engine: official Godot 4.3 stable.

## Changes

- Docks: move the scalper from column 18, over the pit, to supported column 22. Rivals move horizontally and cannot fall onto a floor.
- Docks: add a two-tile one-way step before the three-tile wall. The climb remains possible after enemies have been killed, including with ZOOM. The step is optional if the player uses pogo.
- Roof: expand the Line Cutter deck from 6 to 23 tiles, move the fight farther from the entry ledge, and put the store door toward the far end. The old deck was shorter than ZOOM's shoulder-charge distance; the new deck gives space to dodge.
- No protected scripts, assets, rendering settings, or input settings changed.

## Reproduce verification

Import once with Godot 4.3, then run from the repository root:

```bash
godot --headless --editor --import --quit
godot --headless -s tests/test_bounce.gd
godot --headless -s tests/test_hk.gd
godot --headless -s tests/test_raid.gd
godot --headless --fixed-fps 60 -s tests/test_story_layout.gd
for level in 1 2 3; do
  for fighter in spark zoom brains; do
    godot --headless --fixed-fps 60 -s tests/test_story_routes.gd -- "$level" "$fighter"
  done
done
```

All 13 invocations print `RESULT: PASS`. Story routes use actual inputs and live enemies. They do not teleport, grant health, modify movement, or remove enemies. Each starts at its selected level; they are not one continuous campaign. The Level 3 test calls the exit handler to check the locked gate, defeats the Line Cutter, then physically enters the exit and verifies the boss scene loads. The locked-door collision signal itself still needs a human check. It does not beat the final boss. ZOOM's rooftop combat route uses nail attacks and power shots, rather than its shoulder charge.

This is a headless playtest, not a visual or human difficulty review. The final Level 2 logs still contain the pre-existing coin callback script error below; `PASS` describes the asserted route, not an error-free game.

| Level | SPARK | ZOOM | BRAINS | Intended body gates | Observed deaths per route |
|---|---|---|---|---|---|
| Docks | Exit reached | Exit reached | Exit reached | 1 | 2 |
| Neon Streets | Exit reached | Exit reached | Exit reached | 1 | 2 |
| Roof | Boss scene reached | Boss scene reached | Boss scene reached | 2 | 4 |

The intended gate count is not a proof of the global minimum deaths: enemy pogo routes and advanced movement may allow alternatives. These verified routes trigger two counted deaths per intentional spike fall due to the issue below.

## Needs Abdullah — protected code

1. **Story coins fail.** `story_level.gd` adds each coin before setting `owner`; the coin's `@onready` `%GameManager` lookup therefore runs without the level owner. Godot logs `Node not found: "%GameManager"`; collecting the coin logs `Attempt to call function 'add_point' in base 'null instance'`. Repro: collect a story coin, or run Level 2's route test. Coin rewards remain broken despite the traversal passing.
2. **Spike falls count twice.** In the Roof route, first contact kills at approximately `(79.83, 175.93)` and frame 26; a second death occurs at the respawn `(56, 176)` on frame 62 without further movement. The second gate does the same at the bench. Root cause investigation needs the deferred collision disable/enable and instant-kill contact around respawn in `player.gd`, `game_manager.gd`, and `killzone.gd`; those files were not changed. Repro: run the Roof route and inspect the `DEATH` lines.
3. **Repeated pit falls can escape recovery.** Walk off the first Docks pit and keep returning to it immediately after hazard respawn. `killzone.gd` invokes `player_hit` on entry only; `player_hit` ignores an invulnerable player. If the player re-enters during recovery invulnerability, the pit does not catch them again. A focused input-only reproduction ended at `(301.37, 16424.24)`, alive with 3 masks, below the map.
4. Existing anchor warnings and resource-leak messages appear in baseline tests. The installed Godot 4.6.3 also failed the raid baseline; verification here uses the required 4.3 version.

## Human check and remaining tasks

F5, choose each fighter, and play Docks → Neon Streets → Roof → store. Check sign readability, step visibility, the death overlay, enemy spacing, jump timing, camera bounds, and rooftop combat. For body climbs, land on the body while holding jump, then steer toward the ledge. If the door was entered during the fight, step away and re-enter after defeating the Line Cutter.

Task 1's nine scripted routes are verified, with the protected bugs above still open. Task 2 (secrets), Task 3 (extra guards), and the remaining Task 4 rival placements are not included. This report covers Task 5's observed deaths and unfair behavior; it does not certify minimum deaths. Do not merge or submit the full game as bug-free based on these tests alone.
