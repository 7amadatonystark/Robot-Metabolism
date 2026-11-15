# Controls card import decisions

- Stacked on mazen/game-feel (PR #6), itself stacked on mazen/pause-menu (PR #5), starting from main 97c272c. This PR adds only the controls card and its regression coverage. The resolved autoload configuration is inherited from PR #6.
- Controls are checked against current README Controls/Skills. Existing selected fighter and co-op story behavior are preserved.
- No protected scripts or upstream intro files changed. Game-feel observer fixes belong to the separate effects PR.
- Godot 4.3 with --headless --fixed-fps 60: bounce, hk, raid, hazard_respawn, stats, parry, unchanged upstream intro, and pause all print RESULT: PASS and exit 0. Tests include CROSS activation, d-pad focus, controls back/focus behavior, OPTIONS resume, current co-op story pause, external scene cleanup, and death-time restart/fighter changes. Editor reimport and 120-frame startup exit 0 with no script errors. Existing upstream anchor/resource cleanup warnings remain.
- Godot 4.3 OpenGL Compatibility rendering: captured and inspected the controls card at 1152x648 and 640x360. Reduced row spacing to leave vertical margins at 640x360; all controls remain within the viewport.
- Physical PS4 controller, full visible gameplay flow, and Web export require human validation.
