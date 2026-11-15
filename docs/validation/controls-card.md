# Controls card import decisions

- Stacked on mazen/pause-menu (PR #5), which starts from main 97c272c. This PR adds only the controls card and its regression coverage.
- Controls are checked against current README Controls/Skills. Existing selected fighter and co-op story behavior are preserved.
- No protected scripts or upstream intro files changed. Game-feel observer fixes belong to the separate effects PR.
- Godot 4.3 with --headless --fixed-fps 60: bounce, hk, raid, hazard_respawn, stats, parry, unchanged upstream intro, and pause all print RESULT: PASS and exit 0. Tests include CROSS activation, d-pad focus, controls back/focus behavior, OPTIONS resume, current co-op story pause, external scene cleanup, and death-time restart/fighter changes. Editor reimport and 120-frame startup exit 0 with no script errors. Existing upstream anchor/resource cleanup warnings remain.
- Physical PS4 controller, visible controls layout, and Web export require human validation.
