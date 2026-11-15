# Add observed bounce effects, damage flash, and scene dip

Base: main
Head: mazen/game-feel

Body launches show BOING/dust, downward pogo launches show white sparks, and mask loss by any player flashes white for 0.05 seconds. Temporary effects expire and clear with their world scene. SceneTransition covers scene replacement with a short black dip. Existing protected scene callers swap immediately; this observes the swap and fades in, without delaying outgoing gameplay.

Imports final bundle effects from a3c8de9 and the observer-order correction in 249fdf8 onto main 97c272c. Independent of the pause/controls PRs. Preserves merged intro, current co-op story, store, audio, art, and all protected gameplay code. No new image/audio assets.

Validation: see docs/validation/game-feel.md. Physical PS4 playtesting and Web export remain pending.
