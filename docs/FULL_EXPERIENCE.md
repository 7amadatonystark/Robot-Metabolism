# Before It Drops — full current playtest

This build combines main b2e9644 with walking-animation fix f736254, compact-controls fix 3f3b890, and platform-aware enemy AI 4073293. Branch: mazen/full-experience. Main and the individual review branches remain unchanged.

## Play the whole game

Choose Play, pick SPARK, ZOOM, or BRAINS, and confirm. Advance the story intro to begin The Docks. Continue through Neon Streets and The Roof, defeat the Line Cutter, then fight the Hamster Godfather and the Vice Queen for the ending. Use the normal Play route to experience everything; B on fighter select jumps straight to the bosses.

For local co-op, press R / OPTIONS on fighter select. Up to three players can join in the lobby and play the complete story and bosses together. Controllers join with CROSS; keyboard joins with ENTER.

## Controls

| Action | Keyboard | PS4 |
| --- | --- | --- |
| Move / aim | WASD / arrows | Stick / d-pad |
| Jump | SPACE | CROSS |
| Strike | J / X | SQUARE |
| Pogo | Hold down + strike in the air | Down + SQUARE |
| Dash | K / C / SHIFT | CIRCLE / R1 |
| Fighter special | L | TRIANGLE |
| Power shot | I | R2 / L1 |
| Pause and controls card | ESC | OPTIONS |

Bounce on your old body for extra height, pogo enemies/spikes, strike thrown price tags to reflect them, and rest at benches to heal. The controls card in pause has the complete reference.

## Included

- Three fighters with perks, specials, and visible walking strides.
- Platform-aware enemy patrols, safe hops/landings, spike/wall avoidance, safe Line Cutter charges, and line-of-sight scalper attacks.
- Title, fighter select, story intro, all three current levels and their secrets/routes.
- Line Cutter, Hamster Godfather, Vice Queen, and ending.
- Whole-story local co-op, body bounce/pogo, tag reflection, SOUL, masks, coins, benches, and stats.
- Pause/restart/fighter change, keyboard/PS4 controls card, scene dips, damage flash, bounce dust, sparks, music, sound effects, and the upstream art pass.

## Verification

Godot 4.3: all fifteen tests print RESULT: PASS and exit 0 with --headless --fixed-fps 60. Editor reimport and main-scene startup pass. The enemy AI was additionally checked with all nine level/fighter story routes and three Level 2 secret routes. The user explicitly approved edits to protected guard.gd and rival.gd for the AI fix; other protected scripts and supplied assets are unchanged. Raw results: validation/full-experience.txt and validation/enemy-platform-ai.txt.

The new local copy initially had an incomplete Godot import cache. Reused the verified cache from the animation build (identical asset tree), then reran editor import and the complete suite successfully. The cache is ignored and not committed. Existing upstream resource/ObjectDB shutdown warnings remain. Physical PS4 playtesting, full manual completion, and Web export are not claimed as validated.

The local launch shortcut runs this build maximized at up to 60 FPS using the verified Godot 4.3 engine.
