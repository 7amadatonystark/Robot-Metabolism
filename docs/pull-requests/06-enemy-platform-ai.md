Three lollipop guards walked off Neon Streets' one-tile platforms within about one second of loading, and the roof flame guard could hop into an unsafe landing. Replace direction-dependent cached rays and short landing probes with shared, immediate terrain checks.

Guards/rivals now settle after spawning, patrol without stepping into gaps or spikes, turn before walls, and sweep falling movement so landings cannot skip through floors. Flame guards simulate a hop before committing. The Line Cutter retains its telegraph/charge/stunned cycle and stops safely at edges; preorder enemies hold their shield direction at cliffs; scalpers only shoot with line of sight. Health, damage, speed constants, player mechanics, boss scripts, and level maps remain unchanged.

The user explicitly approved editing the protected scripts/guard.gd and scripts/rival.gd for this task. Those are the only protected files changed. New shared logic is in scripts/enemy_navigation.gd; based on main b2e9644.

Validation: all 14 tests pass in Godot 4.3 with --headless --fixed-fps 60, plus all nine level/fighter scripted routes and all three Level 2 secret routes. New regression coverage exercises all seven enemy kinds on one-tile platforms, swept high-speed landings, safe/unsafe hops, spikes, walls, blocked shots, long charge steps, and all 19 story enemies for ten seconds after loading. Editor import and startup pass. See docs/validation/enemy-platform-ai.txt.

Neon Streets' scripted crossing now uses actual jump/dash/down-strike inputs because the guards no longer disappear before the bot arrives. It still uses real health, enemies and transitions; no position/health overrides or enemy removal were added to the playthroughs. Physical PS4 and Web export remain unverified.
