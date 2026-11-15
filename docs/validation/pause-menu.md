# Pause menu import decisions

- Original bundle published unchanged as mazen/ui-feel-2 at 249fdf8bdf23f0d1678f53bfd685098a57c982fb. Bundle advertises HEAD rather than a named branch; git bundle verify passed against prerequisite 7dd5e8c.
- New work starts at main 97c272c. Omit bundled intro d7d9799 because upstream intro was already merged. Retain upstream intro scene, script, and test byte-for-byte.
- Import pause code from the final bundle state, excluding the separately reviewed controls card. Include controller bindings, focus navigation, and death slow-motion cleanup here so this PR works independently.
- No protected gameplay scripts or existing assets changed. Current Music, Stats, and Sfx autoloads are preserved.
- Godot 4.3 with --headless --fixed-fps 60: bounce, hk, raid, hazard_respawn, stats, parry, upstream intro, and pause all print RESULT: PASS and exit 0. Pause checks exercise synthetic OPTIONS, CIRCLE, CROSS/d-pad navigation, restart, fighter change, co-op boss pause, and death slow-motion cleanup. Editor reimport and 120-frame main-scene startup exit 0 with no script errors. Existing resource/ObjectDB cleanup warnings remain.
- Physical PS4 controller, visible F5 playthrough, and Web export require human validation.
