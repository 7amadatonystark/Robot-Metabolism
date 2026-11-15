# Add observed bounce effects, damage flash and scene dip

Base: mazen/pause-menu (stacked; merge pause first)
Head: mazen/game-feel

Add observer autoloads without changing protected gameplay. Each player's mask loss
flashes white for 0.05s; body launches create BOING/dust, and downward pogo creates
white sparks. Temporary effects expire and are removed with their world scene.
SceneTransition covers outgoing removal/incoming arrival with a short black dip.

Validation: test_feel.gd covers second-player damage/bounces, spawn flash exclusion,
no repeated launch effects, spark/popup cleanup and fade recovery. Existing protected
callers swap scenes immediately, so the dip spans that swap rather than delaying them.
The final stack corrects physics observer callback ordering.
