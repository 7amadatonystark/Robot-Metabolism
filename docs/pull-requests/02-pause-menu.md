# Add keyboard and controller pause menu

Base: main
Head: mazen/pause-menu

Escape/OPTIONS pauses story levels, the co-op story, legacy game scene, and boss arenas. Resume, Restart Level, and Change Fighter work with keyboard, mouse, and controller. Explicit CROSS, d-pad, and left-stick bindings and cyclic focus do not depend on export defaults. Restart/fighter changes restore normal time scale after death slow-motion; external scene changes clear stale pause state.

Reconciled from bundle commits 1020569 and 249fdf8 onto main 97c272c. Preserves the merged story intro and current co-op, store, audio, art, and gameplay code. No protected files changed. Controls card is a separate follow-up PR.

Validation results are recorded in docs/validation/pause-menu.md. Physical PS4 and Web-export checks remain pending.
