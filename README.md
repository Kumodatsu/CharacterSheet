# CharacterSheet
World of Warcraft addon for managing character sheets for roleplaying events and automating relevant calculations.
The source code and all releases are available on the [GitHub page](https://github.com/Kumodatsu/CharacterSheet).
For more information about how to use the addon, see the [wiki](https://github.com/Kumodatsu/CharacterSheet/wiki).

## Setup instructions
### How to download
Go to the [releases page](https://github.com/Kumodatsu/CharacterSheet/releases).
Find the section of the version you want.
The latest version is always on top.
At the bottom of the section, there is a small "Assets" drop down.
Click on it, then click on "CharacterSheet.zip" to download.

### How to install
The downloaded zip file contains a single folder called "CharacterSheet".
Drop this folder (not the zip file itself!) into your AddOns folder `World of Warcraft\_retail_\Interface\AddOns`.
If you run the game now, it should be working.

### How to make backups
The addon saves your data into your World of Warcraft folder.
Account wide data is stored in `World of Warcraft\_retail_\WTF\Account\<account name>\SavedVariables\CharacterSheet.lua`.
Character specific data is stored in `World of Warcraft\_retail_\WTF\Account\<account name>\<server name>\<character name>\SavedVariables\CharacterSheet.lua`.
To make a backup of your data, copy these files somewhere safe.
To restore the data, copy the backup files back to the aforementioned locations.

## Usage (0.4.1)
At the moment, most of the functionality of the addon can be used through the UI.
All of the functionality can be accessed through slash commands.
All commands provided by the addon start with `/cs`.
Use the command `/cs help` to view a listing of all available commands, and `/cs help <command>` to see an explanation of the given command.
The most important use cases of the addon are described below.
See the [wiki](https://github.com/Kumodatsu/CharacterSheet/wiki) for more detailed information.

### Editing your stat block
Use the edit frame to edit your stat block.
The frame can be toggled on and off with the command `/cs toggle edit`.
Use the arrow buttons to add or remove points from a stat.
Click the power level in the top of the frame to change your power level.
At the bottom of the frame, the number of skill points you have left are displayed,
as well as values that are derived from your stats (HP and heal modifier).
Use `/cs validate` to check if your stat block is valid, i.e. you have a valid distribution of SP.
If your stat block is invalid, a message will be displayed telling you what should be changed.

### Using your stats
Click a stat in your stat frame to roll with that stat's modifier.
The stat frame can be toggled on and off with the command `/cs toggle stats`.
You can also use `/cs roll <stat>` to roll with the given stat modifier.
For example, use `/cs roll str` to roll for Strength (1d20 + STR).
Use `/cs heal` to roll for healing in combat (1d14 + heal mod)
and `/cs heal safe` to roll for healing out of combat (1d18 + heal mod).
The heal button will perform a combat heal roll.
The minus and plus buttons next to the HP bar can be used to set your HP.

### Using pets
At the moment, adding and removing pets can not yet be done with the UI.
Use `/cs addpet <name>` to add a pet with the specified name.
Use `/cs setpet <name>` to set the specified pet to be your active one.
Running `/cs setpet` without specifying a name will make your pet inactive.
While you have an active pet, the stats frame will display your pet's HP,
as well as a button to roll for pet attacks.

### TRP3 interoperation
You can optionally give the addon permission to interact with TRP3 if you have it.
By default, this is disabled.
If you enable this, your TRP OOC information will automatically be updated to show your stats
as well as your and your pet's HP whenever these change.
This will replace whatever else you might have had in your OOC information, so make absolutely sure this is what you want!
To enable and disable this option, use `/cs trpstats`.
