# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.8][]
### Changed
- Updated for World of Warcraft 11.0.5.

## [0.6.7][]
### Changed
- Updated for World of Warcraft 11.0.2.
- Roll messages no longer end with a period.
- The power level dropdown menu now actually looks like a dropdown menu.

### Fixed
- Bug where most of the interface would be broken due to a WoW API change.
- The power level dropdown works as intended again.
- Stats are now immediately added to the TRP Currently/OOC information when the
TRP stats setting is set, rather than only after a stat update.
- Stats are now removed from the TRP Currently/OOC information when the TRP
stats setting is turned off.

## [0.6.6][] - 2024-07-29
### Changed
- Updated for World of Warcraft 11.0.0.

### Fixed
- When the pet is toggled, TRP stats are now immediately updated to reflect the
change.
- Fixed a Lua error when trying to open the options menu from the addon
compartment.

## [0.6.5][] - 2024-05-09
### Changed
- Updated for World of Warcraft 10.2.7.

## [0.6.4][] - 2024-03-23
### Changed
- Updated for World of Warcraft 10.2.6.

## [0.6.3][] - 2024-01-22
### Changed
- Updated for World of Warcraft 10.2.5.

### Fixed
- Colors picked in the resource frame will now update the resource immediately,
instead of when other settings change.
- The addon now displays the correct icon in the addon list.
- Fixed Lua errors when stats change with the TRP stats setting on.

## [0.6.2][] - 2023-12-04
### Changed
- Updated for World of Warcraft 10.2.0.
- Updated dependencies.
- The minimap button has been replaced by a new button that integrates with
Blizzard's own addon compartment UI.

### Fixed
- The resource frame works again.

## [0.6.1][] - 2022-09-04
### Changed
- Updated for World of Warcraft 9.2.7.

## [0.6.0][] - 2022-06-01
### Changed
- Updated for World of Warcraft 9.2.5.
- All of the addon's functionality is now accessible through the UI. All the
slash commands still work and exist, but they are no longer essential.

### Added
- Minimap button. This can be used to access the settings menu, to toggle the UI
frames and pet UI, and to access the resource menu.
- Resource menu. It's used to customize or disable your resource bar.
- Command `/cs toggle resource` that toggles the resource menu.

### Fixed
- Fixed a bug where the stats frame was sometimes too short to contain the pet
UI.

## [0.5.11][] - 2022-04-02
### Removed
- April first's fake changelog section.

### Fixed
- Fixed a bug where version numbers greater than 9 were not compared correctly.

## [0.5.9][] - 2022-02-23
### Fixed
- Release notes won't have superfluous line breaks anymore.

### Changed
- Updated for World of Warcraft 9.2.0.

## [0.5.8][] - 2021-11-09
### Added
- A license file. The addon is now licensed under version 3 of the GNU General
Public License. If you are not a software developer, you don't have to care
about this - you are free to use and distribute the addon.
- "Shields" are added to the readme file in the repository to display the latest
version, its download count and the license.

### Changed
- The changelog in the repository now contains links to the version downloads.
- Release notes are now automatically generated from the changelog.
- The folder structure of the repository has changed. If you were using
automated scripts to update this addon, those may have ceased to work. Addon
managers such as Ajour, Overwolf, WoWUp etc. should still work fine with this
addon. If you don't know what this all means, the change likely won't affect you
at all.

## [0.5.7][] - 2021-11-03
### Changed
- Updated for World of Warcraft 9.1.5.
- The folder structure of the repository has changed. If you were using
automated scripts to update this addon, those may have ceased to work. Addon
managers such as Ajour, Overwolf, WoWUp etc. should still work fine with this
addon. If you don't know what this all means, the change likely won't affect you
at all.

## [0.5.6][] - 2021-07-01
### Changed
- Updated for World of Warcraft 9.1.0.

## [0.5.3][] - 2021-04-06
### Changed
- Pets now have the same HP as their owner.

## [0.5.2][] - 2021-03-10
### Changed
- Updated for World of Warcraft 9.0.5.
- Moved a bunch of hardcoded strings into the localization table.

### Fixed
- The messages that display when changing the TRP stats setting no longer
incorrectly state that one's TRP information will be overwritten.

## [0.5.1][] - 2021-01-05
### Changed
- The UI frames are now initially hidden by default.
- The UI frames no longer overlap in their initial positions.

## [0.5.0][] - 2020-12-25
### Added
- Command: `/cs pet`. This toggles your pet. This replaces the old system where
you had to fiddle with pet names and lists and active pets.
- Command: `/cs trpclearstats`. This removes your stats from your TRP info if
they are there while leaving the rest of the contents intact.
- You can now have custom resources, such as Sanity, added to your character
sheet.
- Commands: `/cs addresource`, `/cs removeresource` and `/cs setresource`.
These are used to manage custom resources.
- Keybinds for toggling your pet and incrementing and decrementing pet HP.
- Window for changing the addon's settings in the Interface menu.
- Button for toggling combat on and off in the stats frame. This affects heal
rolls.
- When your save file is from a newer version of the addon than the one you are
currently using, the save file will be ignored until you update the addon to
prevent loss of data.

### Removed
- The pet list.
- Commands: `/cs addpet`, `/cs pets`, `/cs setpet` and `/cs removepet`.
These are no longer necessary.
- Command: `/cs half`. This command didn't really serve a purpose.

### Changed
- Updated for World of Warcraft 9.0.2.
- The saving system has been updated. This means that older saves will no longer
work, but saves made from this version onwards should now always be compatible
with any future versions.
- Your HP and pet HP can now go all the way down to the knock out limit (-5).
- Unmodified (raw) rolls no longer show a (raid) message with the result, as
this is redundant.
- The commands `/cs pethp`, `/cs petatk` and `/cs setpetatk` no longer accept a
pet name is an argument.
- When automatically displaying stats in your TRP is enabled, the stats will now
be placed before your TRP content instead of replacing it.

## [0.4.7][] - 2020-10-25
### Changed
- Heal rolls now use a d10 in combat and a d14 out of combat.

## [0.4.6][] - 2020-10-21
### Added
- String localization. The addon now supports translated strings for other
languages. However, English is currently still the only one available.

### Removed
- Keybind for toggling an obsolete UI frame.

### Fixed
- Keybinds for toggling UI frames now work again.
- When lowering one's power level, stat values will now be reduced if one would
not have enough SP for them anymore. This should now truly make it impossible to
create invalid stat blocks.

## [0.4.5][] - 2020-10-16
### Added
- The power level and stats in the edit frame now show a descriptive tooltip on
mouseover.

### Changed
- It's no longer possible to spend more SP than available, making it impossible
to create any invalid stat blocks.

### Fixed
- When the active pet's max HP changes, this is now updated in the UI
immediately.

## [0.4.4][] - 2020-10-14
### Changed
- Updated for World of Warcraft 9.0.1.

## [0.4.3][] - 2020-10-11
### Changed
- The command `/cs trpstats` now takes an argument to specify whether to use the
TRP Currently, OOC or neither for displaying stats.
- All addon data is now saved in the account wide save file. Loading is
backwards compatible with saves made since version 0.4.0.

## [0.4.1][] - 2020-10-10
### Added
- The stats frame now has buttons to increment and decrement one's HP.
- The stats frame now has a pet HP bar and a pet attack button when a pet is
active.
- The stats frame now has a button to perform a heal roll.
- Optional TRP3 interoperation has been added back. One's TRP OOC information
can optionally be overwritten by one's stats.
- Command: `/cs petatk`. Performs a pet attack roll and displays the final
damage number.
- Command: `/cs setpetatk`. Sets the attribute used to calculate pet attack
damage.
- Command: `/cs setpet`. Sets the currently active pet.
- Command: `/cs trpstats`. Toggles the overwriting TRP OOC information on and
off (it's off by default).
- Command: `/cs trpcur`. Sets one's TRP Currently information.
- Command: `/cs trpooc`. Sets one's TRP OOC information.

### Changed
- The attribute icons in the stats frame no longer have a background.
- The addon's version number is now included in save files, allowing future
versions to handle older save formats.
- A pet from the pet list can now be set to active. This shows their properties
in the stats frame and allows one to omit a pet name in most pet related
commands.
- When using the UI, the chat will no longer get spammed by messages if the UI
itself already provides feedback.
- When using the TRP3 interoperation for displaying stats in the OOC
information, pet HP is now included as well.
- The command `/cs pethp` no longer requires a pet name, and the currently
active pet will be selected when no name is specified.

### Fixed
- The command `/cs addpet` no longer yields a Lua error when not given a pet
name.

## [0.4.0][] - 2020-09-22
### Added
- Stats frame. This is a UI frame that displays one's stat values and allows one
to roll stats with a button click.
- Edit frame. This is a UI frame that allows one to edit their stats.
- Stat rolls now also display the abbreviated name of the used stat in the Raid
chat.
- Command: `/cs version`. Shows the current version number of the addon.

### Removed
- TRP3 interoperation. This was causing Lua errors. TRP3 interoperation will be
added back once a fix has been found.

### Changed
- Roll results are now displayed as a system message when not in a raid or group
or when raid roll messages have been disabled.
- A stat can no longer be set outside of the allowed range.

### Fixed
- (Code) Fixed events triggering callbacks of unrelated events.

## [0.3.2][] - 2020-08-06
### Fixed
- Fixed an error with some output messages resulting in a Lua error.

## [0.3.1][] - 2020-07-26
### Fixed
- When re-enabling raid roll messages after rolling, new rolls will no longer
use incorrect modifers.

## [0.3.0][] - 2020-07-25
### Added
- Roll bonus support. The `/cs roll` command now accepts an additional parameter
that is a bonus to be added to the roll.
- Optional parameter to the `/cs heal` command to specify whether the heal is
done in or out of combat.
- Optional TRP3 interoperation. One's TRP OOC information can optionally be
overwritten by one's stats.
- Command: `/cs trp`. Toggles the overwriting TRP OOC information on and off.
- Key bindings for incrementing and decrementing one's current HP value.
- Roll results are now optionally sent to raid/party chat when in a group.
- (Code) The addon now registers the `CS` prefix for addon messages.
- (Code) Event system. This makes it easier to do event based programming.

### Changed
- The addon's console output is now sent as a system message instead of a Lua
print message.

### Fixed
- When validating a stat block that has too many SP spent, the overflow will no
longer be presented as a negative number.
- Negative numbers in commands are now parsed correctly.

## [0.2.3][] - 2020-07-18
### Fixed
- Setting a stat's value no longer causes a Lua error.

## [0.2.2][] - 2020-07-09
### Added
- Heal modifier. This value is calculated from CHA and added to heal rolls.
- Command: `/cs half`. Helper command to calculate half of a value with
rounding.
- Pets. Characters can now track their pets' HP.
- Command: `/cs addpet`. Adds a pet.
- Command: `/cs pets`. Shows the list of pets a character has.
- Command: `/cs removepet`. Removes a pet.
- Command: `/cs pethp`. Sets a pet's HP.

### Fixed
- One's current HP is now clamped below max HP when the max HP changes due to
stat updates.

## [0.2.1] - 2020-07-07
### Changed
- The README file now contains instructions on how to download, install and use
the addon.

## [0.2.0][] - 2020-07-07
### Added
- Command: `/cs heal`. Allows one to perform a heal roll.
- Command: `/cs level`. Allows one to set their character's power level.
- Command: `/cs validate`. Checks if one's stat block is valid.
- Command: `/cs hp`. Allows one to set their current HP value.
- HP tracking. Max HP is calculated from the stat block and current HP can be
set by the player.
- SP validation. Functionality for checking of a stat block's SP distribution is
valid.
- (Code) Type utilities. Includes functions to facilitate object oriented
programming.

### Removed
- Command: `/cs clear`. The set of available stats is fixed now, so this command
is no longer necessary.
- Optional roll range in `/cs roll`. It will be replaced with a different system
in the future.

### Changed
- Stats and rolls now use the new D&D system.
- Stat names in commands are no longer case sensitive.
- Command descriptions have been made more readable.

### Fixed
- The value given in `/cs set` is now validated before use, preventing errors
when attempting to set a stat to something nonsensical such as
"flipperdipperdoo".

## [0.1.0][] - 2020-07-03
### Added
- Changelog file.
- Command: `/cs clear`. Allows one to clear their stat block.

### Changed
- Some output messages have been improved to make them more accurate and clear.

### Fixed
- Fix handling of events. Event functions are now called, as intended.
- Fix saving and loading of data. This now happens as intended.

## [0.0.3][] - 2020-05-20
### Added
- Basic stat system. Allows one to set stat values and perform rolls.
- Command: `/cs set`. Allows one to create a stat and set its value.
- Command: `/cs roll`. Allows one to roll with a given stat.
- Command: `/cs stats`. Allows one to view their stats and their values.

## 0.0.2 - 2020-05-11
### Added
- (Code) Command system. Creates an abstraction which makes it easier to add new
commands.
- (Code) Table utilities. Includes functions to operate on tables.

[0.6.8]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.8>
[0.6.7]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.7>
[0.6.6]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.6>
[0.6.5]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.5>
[0.6.4]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.4>
[0.6.3]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.3>
[0.6.2]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.2>
[0.6.1]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.1>
[0.6.0]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.6.0>
[0.5.11]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.11>
[0.5.10]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.10>
[0.5.9]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.9>
[0.5.8]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.8>
[0.5.7]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.7>
[0.5.6]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.6>
[0.5.3]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.3>
[0.5.2]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.2>
[0.5.1]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.1>
[0.5.0]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.5.0>
[0.4.7]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.4.7>
[0.4.6]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.4.6>
[0.4.5]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.4.5>
[0.4.4]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.4.4>
[0.4.3]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.4.3>
[0.4.1]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.4.1>
[0.4.0]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.4.0>
[0.3.2]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.3.2>
[0.3.1]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.3.1>
[0.3.0]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.3.0>
[0.2.3]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.2.3>
[0.2.2]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.2.2>
[0.2.0]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.2.0>
[0.1.0]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.1.0>
[0.0.3]: <https://github.com/Kumodatsu/CharacterSheet/releases/tag/v0.0.3>
