# pimon for pico-8

> Pimon is inspired by the traditional [simon game](https://en.wikipedia.org/wiki/Simon_(game)). I implemented a pico-8 version of this classical game to train my brain.

![alt screencast](https://github.com/Milchreis/pimon/blob/main/pimon_0.gif?raw=true "game play")
![alt](https://github.com/Milchreis/pimon/blob/main/pimon-1.p8.png?raw=true "pico 8 cart")
 * [Play it here](https://www.lexaloffle.com/bbs/?tid=46491)
 * [Pico-8 cart](https://github.com/Milchreis/pimon/blob/main/pimon-1.p8.png?raw=true)
 * [Lexaloffle BBS](https://www.lexaloffle.com/bbs/?tid=46491)

# Rules
Pimon plays at first two tones. After that you have to repeat this tones in the correct order. If your are correct pimon will repeat the tones and add one more. Now you have to repeat it again and again ...
If you repeat 4 times the correct tones you get a live up. This allows you once to type in an incorrect answer. After that pimon will repeat the latest tones.

# Controls
Start the game with hitting the `x-button`. As long as pimon plays you can not hit the tone-buttons. On your turn you use the `arrow buttons` to play the tones.

# Background story
Some weeks ago I found the pico 8 platform and it inspired me to start program my own first pico 8 game. I decide to start with a small project to explore the API and documention. The simon game seems for me to be a manageable and great game mechanic for that.

# Changelog
## 1.1
 * New: Dithering effect 
 * New: Animated logo
 * New: Lives and retries
 * Changes: speed increases slower
 * Changes: longer pause on round start
 * Changes: limited speed is a little slower
 * Bugfix: sparkle effect on buttons "flys" on pressed state
 * Bugfix: Latest points not show (always zero)

## 1.0
 * Initial game

