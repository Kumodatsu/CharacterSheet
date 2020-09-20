# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Stats frame. This is a UI frame that displays one's stat values and allows one to roll stats with a button click.
- Edit frame. This is a UI frame that allows one to edit their stats.
- Stat rolls now also display the abbreviated name of the used stat in the Raid chat.
- Command: `/cs version`. Shows the current version number of the addon.

### Removed
- TRP3 interoperation. This was causing Lua errors. TRP3 interoperation will be added back once a fix has been found.

### Changed
- Roll results are now displayed as a system message when not in a raid or group or when raid roll messages have been disabled.
- A stat can no longer be set outside of the allowed range.

### Fixed
- (Code) Fixed events triggering callbacks of unrelated events.

## [0.3.2] - 2020-08-06
### Fixed
- Fixed an error with some output messages resulting in a Lua error.

## [0.3.1] - 2020-07-26
### Fixed
- When re-enabling raid roll messages after rolling, new rolls will no longer use incorrect modifers.

## [0.3.0] - 2020-07-25
### Added
- Roll bonus support. The `/cs roll` command now accepts an additional parameter that is a bonus to be added to the roll.
- Optional parameter to the `/cs heal` command to specify whether the heal is done in or out of combat.
- Optional TRP3 interoperation. One's TRP OOC information can optionally be overwritten by one's stats.
- Command: `/cs trp`. Toggles the overwriting TRP OOC information on and off.
- Key bindings for incrementing and decrementing one's current HP value.
- Roll results are now optionally sent to raid/party chat when in a group.
- (Code) The addon now registers the `CS` prefix for addon messages.
- (Code) Event system. This makes it easier to do event based programming.

### Changed
- The addon's console output is now sent as a system message instead of a Lua print message.

### Fixed
- When validating a stat block that has too many SP spent, the overflow will no longer be presented as a negative number.
- Negative numbers in commands are now parsed correctly.

## [0.2.3] - 2020-07-18
### Fixed
- Setting a stat's value no longer causes a Lua error.

## [0.2.2] - 2020-07-09
### Added
- Heal modifier. This value is calculated from CHA and added to heal rolls.
- Command: `/cs half`. Helper command to calculate half of a value with rounding.
- Pets. Characters can now track their pets' HP.
- Command: `/cs addpet`. Adds a pet.
- Command: `/cs pets`. Shows the list of pets a character has.
- Command: `/cs removepet`. Removes a pet.
- Command: `/cs pethp`. Sets a pet's HP.

### Fixed
- One's current HP is now clamped below max HP when the max HP changes due to stat updates.

## [0.2.1] - 2020-07-07
### Changed
- The README file now contains instructions on how to download, install and use the addon.

## [0.2.0] - 2020-07-07
### Added
- Command: `/cs heal`. Allows one to perform a heal roll.
- Command: `/cs level`. Allows one to set their character's power level.
- Command: `/cs validate`. Checks if one's stat block is valid.
- Command: `/cs hp`. Allows one to set their current HP value.
- HP tracking. Max HP is calculated from the stat block and current HP can be set by the player.
- SP validation. Functionality for checking of a stat block's SP distribution is valid.
- (Code) Type utilities. Includes functions to facilitate object oriented programming.

### Removed
- Command: `/cs clear`. The set of available stats is fixed now, so this command is no longer necessary.
- Optional roll range in `/cs roll`. It will be replaced with a different system in the future.

### Changed
- Stats and rolls now use the new D&D system.
- Stat names in commands are no longer case sensitive.
- Command descriptions have been made more readable.

### Fixed
- The value given in `/cs set` is now validated before use, preventing errors when attempting to set a stat to something nonsensical such as "flipperdipperdoo".

## [0.1.0] - 2020-07-03
### Added
- Changelog file.
- Command: `/cs clear`. Allows one to clear their stat block.

### Changed
- Some output messages have been improved to make them more accurate and clear.

### Fixed
- Fix handling of events. Event functions are now called, as intended.
- Fix saving and loading of data. This now happens as intended.

## [0.0.3] - 2020-05-20
### Added
- Basic stat system. Allows one to set stat values and perform rolls.
- Command: `/cs set`. Allows one to create a stat and set its value.
- Command: `/cs roll`. Allows one to roll with a given stat.
- Command: `/cs stats`. Allows one to view their stats and their values.

## [0.0.2] - 2020-05-11
### Added
- (Code) Command system. Creates an abstraction which makes it easier to add new commands.
- (Code) Table utilities. Includes functions to operate on tables.
