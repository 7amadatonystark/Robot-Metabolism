# Platform-aware enemy AI — 2026-11-15

## Diagnosis

On unmodified main, a fixed-seed passive stage-load check reproduced three lollipop guards falling from the Neon Streets columns at frame 64 and a roof flame guard falling later. The original two-frame layout test passed, so it could not detect the patrol failure.

Edge rays were read after changing their positions/directions, before the cached physics result matched that direction. On a 16-pixel column, an eight-pixel look-ahead also sits right at its boundary. Guards only turned while their center still detected ground; after walking beyond it, they kept falling. The four-pixel landing probe could miss a floor during fast vertical movement. Rivals moved horizontally without a reliable landing step.

## Decisions

- User explicitly approved edits to protected scripts/guard.gd and scripts/rival.gd. No other protected files changed. Level maps and assets are unchanged.
- Shared EnemyNavigation performs current collision queries, checks each short segment of a step, uses a two-pixel support margin, accounts for body width at walls, and avoids hazardous areas. If neither patrol direction is safe, the enemy waits.
- Allow two physics frames for freshly generated collision to register before choosing a patrol direction. Initialize rightward patrol explicitly to preserve the old effective first-frame heading without depending on a cold-ray reversal.
- Falling movement sweeps the full vertical travel distance. Flame hops are predicted using the same gravity, rise/descent speeds and physics interval; unsafe or spike landings are rejected and reconsidered later.
- Keep existing enemy roles, HP, damage, speed constants, shield rules, and Line Cutter states. The charging enemy becomes stunned when terrain blocks it; the scalper checks visibility. This is terrain-aware local navigation, not whole-map pathfinding.
- Retain real-input playthrough assertions. The Level 2 bot now uses jump/dash/down-strike to cross guarded columns, instead of depending on enemies falling away. No test health/position overrides were added to those route or secret tests.

## Validation

Godot 4.3.stable.official.77dcf97d8, --headless --fixed-fps 60:

- All fourteen tests on the AI branch: PASS, exit 0.
- All nine combinations of three story levels and three fighters: PASS, including the Line Cutter gate fight and actual exits.
- All three fighter routes to the Level 2 secret: PASS.
- New AI test: every enemy kind stays on a 16-pixel platform and still moves; flame can perform a safe hop; fast falls land; patrols avoid walls/spikes; blocked shots are not fired; a large charge step cannot skip a gap. All nineteen story enemies remain supported over ten-second passive load checks.
- Editor reimport and main-scene startup: PASS. Existing anchor/resource/ObjectDB shutdown warnings remain. Earlier failed bot attempts were resolved by the real-input crossing strategy above.

Raw final summaries: enemy-platform-ai.txt. Physical PS4 playtesting and Web export remain unverified.

Human: start Neon Streets and watch the first three columns before moving. Approach shield enemies near an edge, bait a flame hop toward a gap, and bait the Line Cutter into a ledge/wall. Enemies should remain active without walking or charging into pits; safe hops, combat and the exit gate should still work.
