# CharacterSheet
World of Warcraft addon for managing character sheets for roleplaying events and automating relevant calculations.
The source code and all releases are available on the [GitHub page](https://github.com/Kumodatsu/CharacterSheet).

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

## Usage (0.4.0)
At the moment, most of the functionality of the addon can be used through the UI.
All of the functionality can be accessed through slash commands.
All commands provided by the addon start with `/cs`.
Use the command `/cs help` to view a listing of all available commands, and `/cs help <command>` to see an explanation of the given command.
The most important use cases of the addon are described below.

### Editing your stat block
Use the edit frame to edit your stat block.
The frame can be toggled on and off with the command `/cs toggle edit`.
Use the arrow buttons to add or remove points from a stat.
Click the power level in the top of the frame to change your power level.
At the bottom of the frame, the number of skill points you have left are displayed,
as well as values that are derived from your stats (HP and heal modifier).

### Validating your stat block
Use `/cs validate` to check if your stat block is valid, i.e. you have a valid distribution of SP.
If your stat block is invalid, a message will be displayed telling you what should be changed.

### Using your stats
Click a stat in your stat frame to roll with that stat's modifier.
The stat frame can be toggled on and off with the command `/cs toggle stats`.
You can also use `/cs roll <stat>` to roll with the given stat modifier.
For example, use `/cs roll str` to roll for Strength (1d20 + STR).
Use `/cs heal` to roll for healing in combat (1d14 + heal mod)
and `/cs heal safe` to roll for healing out of combat (1d18 + heal mod).
At the moment, heal rolls can not yet be performed through the UI, so you need to use the command.
You can change your HP either by configuring keybinds for incrementing and decrementing your HP value
or by using `/cs hp <value>`.
At the moment, changing your HP can not yet be performed through the UI.
Pet HP and pet attack rolls have also not yet been incorporated into the UI.
