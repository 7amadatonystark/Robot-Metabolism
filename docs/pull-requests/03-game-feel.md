# Add observed bounce effects, damage flash, and scene dip

Base: mazen/pause-menu (PR #5; merge pause first)
Head: mazen/game-feel

Body launches show BOING/dust, downward pogo launches show white sparks, and mask loss by any player flashes white for 0.05 seconds. Temporary effects expire and clear with their world scene. SceneTransition covers scene replacement with a short black dip. Existing protected scene callers swap immediately; this observes the swap and fades in, without delaying outgoing gameplay.

Imports final bundle effects from a3c8de9 and the observer-order correction in 249fdf8 onto main 97c272c. Stacked on the pause PR to resolve the shared project.godot autoload insertion in advance; effects code does not depend on pause. Preserves merged intro, current co-op story, store, audio, art, and all protected gameplay code. No new image/audio assets.

Validation: see docs/validation/game-feel.md. Physical PS4 playtesting and Web export remain pending.
