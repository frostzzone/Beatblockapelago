# Beatblockapelago <!-- omit in toc -->

An Archipelago mod for Beatblock

- [Note](#note)
- [Gameplay](#gameplay)
- [Installation](#installation)
  - [Beatblockapelago](#beatblockapelago)
  - [lua-apclientpp](#lua-apclientpp)
- [AP World](#ap-world)
- [Todo](#todo)

## Note

- ### [lua-apclientpp](https://github.com/black-sliver/lua-apclientpp) only has windows builds (:sadcranky:)

## Gameplay
After generating a seed, every level is locked behind an item that can be found in the archipelago world.

Locations(Checks) are beating a level with at least the rank set in the yaml file.

The goal is to beat the set level at the chosen rank

## Installation

Download the mod from the [releases page](https://github.com/frostzzone/Beatblockapelago/releases/latest)

You will need [beatblockplus](https://github.com/BeatblockTools/BeatblockPlus/releases/latest) follow their [install guide](https://beatblocktools.github.io/docs/installation/installing-lovely-and-bbp).


### Beatblockapelago

Take the mod zip and drag it into the mod menu ingame.

<img src="https://beatblocktools.github.io/assets/images/drag-and-drop-9dcaae500f076a205fc90bf9b5c3d6a5.gif">


### lua-apclientpp

*(I didnt know where to put the dll)*

Go into the mod folder via `%appdata%\beatblock\Mods` or the `Open Mods Folder` button ingame.

Go to `ap-block\lua-apclientpp` and drag the `lua-apclientpp.dll` file to the root folder of your game.

## AP World
If apworld fails to generate, try again please

My code is awful so the randomization isnt the best 

- TODO

## Todo
(kinda in order of priority)

- [X] Ranksanity
- [X] Fishsanity
- [X] Choosing goal level's goal rank
- - [ ] Deathlink
  - [ ] Send
  - [ ] Receive
  - [ ] Fully Implemented in game
- [ ] Add a way to add custom/workshop levels into the randomizer
- [X] Allow choosing target rank
- [ ] Add marathons to the pool
- [ ] Add costumes to the pool
- [ ] Add level unlocks as a location (needs costumes and marathons)
  - Basically, the special clear condition level unlocks (the ones with cutscenes)
- [ ] Add traps
- [ ] Lock Note types???