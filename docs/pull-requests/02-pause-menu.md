# Add pause menu for story levels and boss raids

Base: mazen/story-intro (stacked; merge intro first)
Head: mazen/pause-menu

Add ALWAYS-processing PauseMenu autoload. Escape/OPTIONS pauses gameplay only;
Resume, Restart Level and Change Fighter use normal Controls and restore unpaused
state before scene changes. External scene changes clear stale overlays.

Validation: test_pause.gd covers menu exclusion, Escape/OPTIONS/CIRCLE, restart,
fighter select and co-op boss pause. The final controls-card PR adds explicit pad UI
bindings and a death slow-motion cleanup regression; merge the complete stack.
