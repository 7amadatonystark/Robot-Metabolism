# Game feel import decisions

- Starts from current main 97c272c; omits bundled duplicate intro and pause/controls changes.
- Imports final observer code, including process_physics_priority=100. Watches each player independently; no gameplay movement, damage, protected files, or existing assets changed.
- SceneTransition's black dip spans immediate scene replacement. A full delayed fade-out would require changes to protected callers and is deliberately out of scope.
- Godot 4.3 with --headless --fixed-fps 60: bounce, hk, raid, hazard_respawn, stats, parry, unchanged upstream intro, and feel all print RESULT: PASS and exit 0. Feel checks exercise second-player damage, spawn exclusion, BOING/dust, no repeated launch effects, pogo sparks, cleanup, and scene-dip recovery. Editor reimport and 120-frame main-scene startup exit 0 with no script errors. Existing resource/ObjectDB cleanup warnings remain.
- Physical PS4 controller, visible playthrough/effects appearance, and Web export require human validation.
