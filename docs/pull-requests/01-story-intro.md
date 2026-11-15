# Add story intro between fighter select and Level 1

Base: main
Head: mazen/story-intro

Fighter select already checks for intro.tscn. Add that scene and intro.gd to display
Levels.STORY on black with the existing pixel font. A fresh key/CROSS press reveals the
line, then advances it; the last line starts story level 1. No protected scripts changed.

Validation: test_intro.gd prints RESULT: PASS. Echo is ignored; CROSS reveals/advances;
the final press loads story_level.tscn with level_index=1. See MAZEN_WORK_LOG.md for
existing gameplay diagnostics and Godot-version/hardware limits.
