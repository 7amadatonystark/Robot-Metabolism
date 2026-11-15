# Agent brief: ZIKO (Level Designer)

You're Ziko's coding agent. Ziko owns **the levels**: where the fun and the theme happen.
Read `/AGENTS.md` first (hard rules + progress report). Branch name: `ziko/levels`.

## Your goal
The story levels are built from **text maps** in `scripts/levels.gd` (1 character = 1 tile). Edit the maps; no scene editing needed. Press F5, pick a fighter, and play.
Legend: `#` ground · `=` one-way platform · `X` death spikes · `P` start · `B` bench · `C` coin · `g`/`h`/`f` guards (lollipop / smug / flame) · `E` exit · `1`-`9` signs (text in `"signs"`) · `.` empty (below the map = pit).

## Numbers (tile = 16 px)
- Normal jump ≈ 2.9 tiles up, ≈ 5 tiles across. Pogo ≈ 2.9 tiles up from the hit point.
- Body bounce ≈ 5.6 tiles (hold jump ≈ 8). Dash ≈ 3.3 tiles across (1 air dash).
- Walls of 3 tiles need a pogo. Walls of 5 tiles need a body bounce (put `X` spikes right in front).

## Tasks (in order; report after each)
1. **Playtest Levels 1-3** with every fighter. Each must be beatable. Fix anything impossible or boring by editing the maps.
2. **Add 1-2 secrets per level:** coins on high ledges reachable only by a body bounce or a pogo chain.
3. **Balance guards:** more guards in Level 2, a flame guard on the Level 3 ledge.
4. **Report** the minimum deaths per level and anything unfair.

## Done when
All 3 levels can be beaten start to finish, each goal loads the next level, and the Level 3 exit leads to the boss (already wired).
