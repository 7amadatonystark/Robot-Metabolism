# Add keyboard and PS4 controls card

Base: mazen/game-feel (PR #6; merge #5, then #6, then this PR)
Head: mazen/controls-card

CONTROLS opens a keyboard/PS4 reference from the paused menu. CROSS opens the card, CIRCLE/Escape returns focus to CONTROLS, and OPTIONS resumes gameplay directly. The card includes movement/aim, jumping, directional attacks/pogo, dash, specials, power shot, and menu controls.

Imports the controls portion of bundle commit 249fdf8. Controller bindings, cyclic button focus, and death slow-motion fixes already belong to the pause PR; effects belong to PR #6. The reviewed stack includes the resolved autoload configuration, avoiding a later project.godot conflict. No duplicate intro or protected gameplay changes. The base branch descends from main 97c272c.

Validation: see docs/validation/controls-card.md. Physical PS4 controller and Web export remain pending.
