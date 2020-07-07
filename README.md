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

## Usage (latest version)
At the moment, all interactions with the addon happen through commands.
A UI will be coming in the future.

All commands provided by the addon start with `/cs`.
Use the command `/cs help` to view a listing of all available commands, and `/cs help <command>` to see an explanation of the given command.
The most important use cases of the addon are described below.

### Editing your stat block
Use the command `/cs stats` to view your stat block.
Initially your power level and stats all have default values.
To change your power level, use `/cs level <name>` where `<name>` is one of Novice, Apprentice, Adept, Expert and Master (case insensitive).
For example, use `/cs level adept` to set your power level to Adept.
To edit a stat's value, use `/cs set <stat> <value>` where `<stat>` is one of STR, DEX, CON, INT, WIS, CHA (case insensitive).
For example, use `/cs set str 15` to set your Strength to 15.
Use `/cs hp <value>` to set your current HP to the given value.
Your max HP and SP are automatically calculated from your power level and stats.

### Validating your stat block
Use `/cs validate` to check if your stat block is valid, i.e. you have a valid distribution of SP.
If your stat block is invalid, a message will be displayed telling you what should be changed.

### Rolling
Use `/cs roll <stat>` to roll with the given stat modifier.
For example, use `/cs roll str` to roll for Strength (1d20 + STR).
Use `/cs heal` to roll for healing (1d14).
