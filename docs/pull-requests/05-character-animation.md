SPARK used its standing idle poses while moving, and the small pose changes in the other fighters' sheets made movement read as sliding. Add a presentation layer that draws alternating leg strides and a small body bounce from each fighter's existing animation frame.

The stride follows movement distance and direction for each player independently. Idle, jump, attack, dash, hurt, and death use the original sprite unchanged. The walking layer inherits the existing outline and hit/invulnerability tint. No new artwork, textures, movement rules, or protected scripts are changed.

Based on main b2e9644, preserving the latest co-op story, levels, and final boss. The original clone/playtest branch is preserved in a separate worktree.

Validation: all 14 tests pass under Godot 4.3 with --headless --fixed-fps 60, including a new movement/visual-handoff regression for all three fighters and co-op independence. Editor import and startup pass. Rendered and inspected stride poses on the laptop's OpenGL Compatibility renderer. See docs/validation/character-animation.txt. Physical PS4 and Web export remain unverified.
