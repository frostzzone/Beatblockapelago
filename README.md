# Beatblockapelago

An Archipelago mod for Beatblock

- [Beatblockapelago](#beatblockapelago)
  - [Gameplay](#gameplay)
  - [Installation](#installation)
    - [Beatblockapelago](#beatblockapelago-1)
    - [lua-apclientpp](#lua-apclientpp)
  - [AP World](#ap-world)
  - [Yaml](#yaml)
  - [Todo](#todo)



## Gameplay
After generating a seed, every level is locked behind an item that can be found in the archipelago world.

Locations(Checks) are beating a level with at least the rank set in the yaml file.

The goal is to beat the set level at the chosen rank

## Installation

You will need [beatblockplus](https://github.com/BeatblockTools/BeatblockPlus/releases/latest) follow their [install guide](https://beatblocktools.github.io/docs/installation/installing-lovely-and-bbp).


### Beatblockapelago

Download the mod from the releases (TODO) <!--[releases page](https://github.com/frostzzone/Beatblockapelago/releases/latest)-->

Then drag it into the mod menu ingame.

<img src="https://beatblocktools.github.io/assets/images/drag-and-drop-9dcaae500f076a205fc90bf9b5c3d6a5.gif">


### lua-apclientpp

Go into the mod folder via `%appdata%\beatblock\Mods` or the `Open Mods Folder` button ingame.

Go to `ap-block\lua-apclientpp` and drag the `lua-apclientpp.dll` file to the root folder of your game.

## AP World

- TODO

## Yaml

- TODO

## Todo
(kinda in order of priority)

- [ ] Deathlink (Not implemented)
  - [X] Send
  - [X] Receive
- [X] Ranksanity
  - [ ] Implemented in game
- [X] Fishsanity (Not implemented clientside)
  - [ ] Implemented in game
- [ ] Choosing goal level's goal rank
- [ ] Add a way to add custom/workshop levels into the randomizer
- [X] Allow choosing target rank
- [ ] Add marathons to the pool
- [ ] Add costumes to the pool
- [ ] Add level unlocks as a location (needs costumes and marathons)
- [ ] Add traps
- [ ] Lock Note types