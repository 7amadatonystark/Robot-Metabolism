# Add controls card and finish controller navigation

Base: mazen/game-feel (stacked; merge effects first)
Head: mazen/controls-card

Add CONTROLS to pause with keyboard/PS4 mappings. CROSS opens the card; CIRCLE/Escape
returns focus to CONTROLS; OPTIONS resumes. Register duplicate-safe controller UI
bindings and explicit cyclic button focus. Restore normal time scale when restart or
fighter change interrupts a death sequence. Correct effect observer physics ordering.

Validation: all nine test_*.gd scripts print RESULT: PASS with --fixed-fps 60 under
Godot 4.6.3. Editor import and F5-equivalent headless main-scene smoke were also run.
New tests cover actual pad events and death-time restart/fighter changes. Independent
review checked rapid scene swaps, external pause cleanup and controls layout. Actual
Godot 4.3, physical PS4 and browser export are still human validation steps.

Full record: docs/MAZEN_WORK_LOG.md and docs/validation/mazen-tests.txt.
