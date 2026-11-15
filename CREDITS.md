# Credits & code origin

## Base project: 100% human-written tutorial
- **Brackeys, "How to make a Video Game - Godot Beginner Tutorial"** (YouTube, Apr 2024): https://www.youtube.com/watch?v=LOhfqjmasi0
- Source: https://github.com/Brackeys/first-game-in-godot, released into the **public domain** (Unlicense, see `LICENSE-brackeys.txt`).

## Assets: 100% human-made, none AI-generated
- **Brackeys Platformer Bundle** (CC0): https://brackeysgames.itch.io/brackeys-platformer-bundle
  - Sprites from asset packs credited by Brackeys; music by Sofia Thirslund; sounds by Asbjørn Thirslund; font by Jayvee Enaguas (HarvettFox96).
- All files in `assets/` are byte-for-byte identical to the Brackeys originals (checked).

## Audit vs. the original tutorial (checked file by file)
| File | Status |
|---|---|
| `scripts/coin.gd`, `scripts/slime.gd` | Unchanged Brackeys |
| `scenes/player.tscn`, `slime.tscn`, `coin.tscn`, `platform.tscn`, `music.tscn`, `killzone.tscn` | Unchanged Brackeys |
| `scenes/game.tscn` | Brackeys + 1 line (`leaves_body = false` on the pit killzone) |
| `scripts/player.gd` | Brackeys base + team additions (bounce, die, respawn) |
| `scripts/game_manager.gd` | Brackeys base + team additions (deaths, bodies, respawn, HUD) |
| `scripts/killzone.gd` | Brackeys base, death now handled by game manager |
| `scripts/body_pad.gd`, `scripts/checkpoint.gd`, `scenes/checkpoint.tscn` | New: our mechanic |
| `tests/*` | New: test and demo tools (not part of the game) |

Team additions were written with AI coding help, which our local event allows for code. Every script starts with an `ORIGIN:` comment saying where it came from.
