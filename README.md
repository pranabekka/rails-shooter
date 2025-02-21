pew pew goes the little arrow thing

using:

- [jj 0.26.0](https://github.com/jj-vcs/jj#readme)

- [godot 4.3](https://godotengine.org)

play on:

[pranabekka.itch.io](https://pranabekka.itch.io/rails-shooter-prototype)

decisions:

- random colours for fun
  and (in the future) different players and levels
  without baking things into files

- ok_hsl colours to keep perceived lightness
  consistent across different hues
  (base blue is otherwise darker than base yellow)

- single main code file (root.gd)
  to write everything in one go
  while i'm just messing around.
  will clean up in future

- bawx data as json string
  because i don't want to create separate scripts
  with duplicated info,
  or a bawx class with base script

- connect signals through code
  because i like the explicitness of code
  and i can type it out with everything else.
  change it later so godot can (probably)
  hook up signals at compile time
  instead of when my code executes at runtime
