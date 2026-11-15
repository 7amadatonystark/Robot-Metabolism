# Character movement animation — 2026-11-15

User report: fighter looks static while moving.

Diagnosis: actual movement playback visits all four SPARK frames and all five ZOOM/BRAINS run frames. The animation clock is not stuck. SPARK maps run to idle and has no dedicated run art; the small existing poses make the fighters look like they slide.

Fix: a new FighterMotion autoload attaches a visual WalkPose to each custom fighter's AnimatedSprite2D. It reuses the current texture's leg and torso regions at draw time, adding alternating hip rotation/foot lift and a small torso bounce. No generated artwork or saved bitmap assets. Original frame playback and shader/tint remain active. No protected files changed.

The pose is visible only for grounded movement outside attack, dash, stun, or death. Every other state restores the original sprite. Each fighter owns its own stride phase; collision, position, speed, masks, and combat are untouched. The original Brackeys knight keeps its existing frame animation.

This is procedural movement using the supplied art, not a newly drawn run sprite sheet. A future artist-supplied sheet could replace it.

Validation: all 14 test scripts, editor reimport, and startup pass under Godot 4.3. Rendered twelve enlarged stride poses across the three fighters and inspected them with the OpenGL Compatibility renderer. Existing resource/ObjectDB shutdown warnings remain. Raw results: character-animation.txt.

Human: choose each fighter, walk both ways, stop, jump, attack, dash, and take damage. In co-op, move one fighter while another stands or attacks. Pause should freeze the stride; resume should continue naturally. Physical PS4 and Web export remain unverified.
