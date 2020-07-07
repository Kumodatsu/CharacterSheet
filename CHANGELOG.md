# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
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
- The value given in `/cs set` is now validated before use, preventing errors when attempting to set a stat to something nonsensical such as "flipperdipperdoo".
- Command descriptions have been made more readable.

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
