# CharacterSheet
![version number][shield-version]
![download count][shield-downloads]
![GNU GPLv3 license][shield-license]

World of Warcraft addon for managing character sheets for roleplaying events and
automating relevant calculations. The source code and all releases are available
on the [GitHub page][1]. For more information about how to use the addon, see
the [wiki][2].

This addon is made specifically for the guilds Motley Drifters and Ventures
Hearth on Argent Dawn EU. If you are not in these guilds you are still free to
use the system and addon for your own events and guilds. Just keep in mind that
neither the system nor the addon were intended for widespread use and their
mechanics may change in unforeseen ways.

## Setup instructions
### How to download
Go to the [releases page][3]. Find the section of the version you want. The
latest version is always on top. At the bottom of the section, there is a small
"Assets" drop down. Click on it, then click on "CharacterSheet.zip" to download.

### How to install
The downloaded zip file contains a single folder called "CharacterSheet". Drop
this folder (not the zip file itself!) into your AddOns folder
`World of Warcraft\_retail_\Interface\AddOns`. You can test if everything went
well by running the command `/cs version`. If you see the addon's version in
(the general tab of) your chat, the addon should be working correctly.

### How to make backups
The addon saves your data into your World of Warcraft folder. All data is stored
in `World of Warcraft\_retail_\WTF\Account\<account name>\SavedVariables\CharacterSheet.lua`.
To make a backup of your data, copy this file somewhere safe. To restore the
data, copy the backup file back to the aforementioned location.

## Usage (latest version)
All of the functionality can be used either through the UI or slash commands.
All commands provided by the addon start with `/cs`.
Use the command `/cs help` to view a listing of all available commands, and
`/cs help <command>` to see an explanation of the given command.
The most important use cases of the addon are described below.

### Editing your stat block
Use the edit frame to edit your stat block.
The frame can be toggled on and off through the minimap menu, or with the
command `/cs toggle edit`.
Use the arrow buttons to add or remove points from a stat.
Click the power level in the top of the frame to change your power level.
At the bottom of the frame, the number of skill points you have left are
displayed, as well as values that are derived from your stats (HP and heal
modifier).
It is impossible to create invalid stat blocks.

### Using your stats
Use the stat frame to perform rolls and modify you and your pet's health.
The stat frame can be toggled on and off through the minimap menu, or with the
command `/cs toggle stats`.
Click a stat in your stat frame to roll with that stat's modifier.
You can also use `/cs roll <stat>` to roll with the given stat modifier.
For example, use `/cs roll str` to roll for Strength (1d20 + STR).

The heal button will perform a heal roll.
Click the combat icon next to the button to switch between out of combat
("safe") and in combat heals.
The minus and plus buttons next to the HP bar can be used to set your HP.

You can add a custom resource, such as Sanity or anything else, to your stats
frame.
Click the "Manage resource" option in the minimap menu, or use the command
`/cs toggle resource`.
Enter a name, minimum and maximum value, and colors for the display bar.
The resource bar will then appear in your stats frame under your health bar.
Click the "Disable resource" button to remove the resource.

### Using pets
You can toggle a pet using the minimap menu.
This will add the pet UI to your stats frame.
Click the pet attack button to perform a pet attack roll.
The total damage value of the attack is displayed in the chat.

Use `/cs setpetatk <stat>` to set the stat used to calculate pet attack damage
to something other than Charisma.
You should only do this with permission of the game master!

### TRP3 interoperation
You can optionally give the addon permission to interact with TRP3 if you have
it. By default, this is disabled. If you enable this, your TRP Currently or OOC
information will automatically be updated to show your stats, your and your
pet's HP and your extra resource whenever these change. To have your Currently
updated, use `/cs trpstats cur`. To have your OOC updated, use
`/cs trpstats ooc`. To disable this altogether, use `/cs trpstats off` (this is
the default). The stats will _not_ overwrite what you had already written, it
will simply be put before it. Use `/cs trpclearstats` to remove the stats from
your TRP and leave only the information you had written yourself.

[1]: <https://github.com/Kumodatsu/CharacterSheet>
[2]: <https://github.com/Kumodatsu/CharacterSheet/wiki>
[3]: <https://github.com/Kumodatsu/CharacterSheet/releases>

[shield-version]: <https://img.shields.io/github/v/release/Kumodatsu/CharacterSheet?color=%2300aa00&include_prereleases&label=Version&style=flat-square>
[shield-downloads]: <https://img.shields.io/github/downloads-pre/Kumodatsu/CharacterSheet/latest/total?color=%2300aa00&label=Downloads&style=flat-square>
[shield-license]: <https://img.shields.io/github/license/Kumodatsu/CharacterSheet?label=License&style=flat-square>
