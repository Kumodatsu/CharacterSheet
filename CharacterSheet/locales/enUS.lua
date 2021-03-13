local addon_name, CS = ...

local multiline = CS.Util.multiline

CS.Locale.Translations["enUS"] = CS.Locale.Translation {
    POWER_LEVEL        = "Power Level",
    NOVICE             = "Novice",
    APPRENTICE         = "Apprentice",
    ADEPT              = "Adept",
    EXPERT             = "Expert",
    MASTER             = "Master",
    DESC_POWER_LEVEL   = "Your power level grants you additional skill points to allocate, and additional base health.",
    DESC_STR           = "Measuring physical power.\nStrength covers bodily prowess, and the extent of one's raw physical force.\nStrength typically governs attacks with conventional weapons - straight swords, axes, maces, two handers, etc.\nStrength can also influence one's ability to clear an obstacle with force, or intimidate an unruly individual.",
    DESC_DEX           = "Measuring agility.\nDexterity governs one's agility, reflexes, balance, and finesse.\nDexterity typically governs ranged weaponry and attacks, precision attacks, small weaponry like daggers, and finesse weapons like short-swords and some polearms.",
    DESC_CON           = "Measuring endurance.\nConstitution governs health, stamina, and vital force - influencing one's physical endurance and survivability.\nEvery point in Constitution adds one point to your maximum health.",
    DESC_INT           = "Measuring reasoning and memory.\nGoverns mental acuity, accuracy of one's memory, and the ability to reason.\nInfluences traditional spellcasting via the arcane.\nOften influences one's ability to understand puzzles and conundrums.",
    DESC_WIS           = "Measuring perception and insight.\nGoverns one's world knowledge and awareness, perceptiveness, and intuition.\nInfluences one's ability to understand a foreign location, deduce an enemy's weaknesses, etc.\nAffects the power of spellcasters whose power is sought through faith (i.e. shaman, paladins and priests).",
    DESC_CHA           = "Measuring force of personality.\nGoverns one's ability to sway and influence others, either by confidence, eloquence, or otherwise.\nAffects the power of adventurers with summoned familiars or pets as primary attack methods (beast masters, demonologists, etc.).\nEvery two points above 10 in Charisma add one point to your healing modifier.",
    STR                = "STR",
    DEX                = "DEX",
    CON                = "CON",
    INT                = "INT",
    WIS                = "WIS",
    CHA                = "CHA",
    HP                 = "HP",
    SP                 = "SP",
    ACTIVE             = "active",
    NATURAL            = "NATURAL",
    AVAILABLE_COMMANDS = "Available commands:",
    PET                = "Pet",
    -- 1: HP, 2: heal mod, 3: SP
    DERIVED_STATS      = "HP: %1$d\nHeal mod: +%2$d\nSP: %3$d",

    MSG_AVAILABLE_COMMANDS         = "Available commands:",
    MSG_POSITIVE_INTEGER           = "The value must be a positive integer.",
    MSG_INTEGER                    = "The value must be an integer.",
    MSG_REQUIRE_VALUE              = "You must specify a value.",
    -- 1: min, 2: max
    MSG_RANGE                      = "The value must be in the range [%1$d, %2$d].",
    -- 1: stat
    MSG_INVALID_STAT               = "%1$s is not a valid stat.",
    -- 1: stat, 2: value
    MSG_STAT_SET                   = "%1$s set to %2$d.",
    -- 1: parameter list
    MSG_ALLOWED_PARAMETERS         = "Parameter must be one of %1$s.",
    MSG_REQUIRE_PET_NAME           = "You must specify one of your pets' names.",
    MSG_REQUIRE_PET_ACTIVE_OR_NAME = "You must have a pet active or specify one of your pets' names.",
    MSG_REQUIRE_VALID_ATTRIBUTE    = "You must specify a valid stat attribute.",
    -- 1: pet name
    MSG_NAME_IS_NOT_PET            = "You don't have a pet named %1$s.",
    -- 1: stat
    MSG_PET_ATK_SET                = "Pet attack attribute set to %1$s.",
    -- 1: power level
    MSG_INVALID_POWER_LEVEL        = "%1$s is not a valid power level.",
    -- 1: power level
    MSG_POWER_LEVEL_SET            = "Power level set to %1$s.",
    MSG_VALID_STAT_BLOCK           = "Your stat block is valid.",
    MSG_SET_HP_ALLOWED_PARAMETERS  = "The given value must be a number or \"max\".",
    MSG_SET_HP_ALLOWED_VALUES      = "The given value must be between the knock out limit and your max HP (inclusive).",
    -- 1: HP
    MSG_HP_SET                     = "HP set to %1$d.",
    MSG_MISSING_PET_NAME           = "You must specify a name for your pet.",
    -- 1: name
    MSG_PET_ALREADY_EXISTS         = "You already have a pet named %1$s.",
    -- 1: name
    MSG_PET_ADDED                  = "Added pet named %1$s.",
    -- 1: name
    MSG_PET_REMOVED                = "Removed pet %1$s.",
    MSG_NO_PETS                    = "You do not have any pets.",
    MSG_SET_PET_HP_ALLOWED_VALUES  = "The given value must be between the knock out limit and your pet's max HP (inclusive).",
    -- 1: HP
    MSG_PET_HP_SET                 = "Pet HP set to %1$d.",
    -- 1: name
    MSG_ACTIVE_PET_SET             = "%1$s is now your active pet.",
    MSG_ACTIVE_PET_UNSET           = "You no longer have an active pet.",
    MSG_INVALID_NUMBER             = "You must specify a valid number.",
    -- 1: attribute, 2: min, 3: max
    MSG_ATTRIB_RANGE               = "The attribute %1$s must be in the range [%2$d, %3$d].",
    -- 1: SP
    MSG_TOO_MANY_SP                = "You have spent %1$d too many SP.",
    -- 1: SP
    MSG_UNSPENT_SP                 = "You still have %1$d unspent SP.",
    MSG_RAID_ROLL_ENABLED          = "Raid roll messages are now ENABLED.",
    MSG_RAID_ROLL_DISABLED         = "Raid roll messages are now DISABLED.",
    -- 1: command
    MSG_UNKNOWN_COMMAND            = "Unknown command: %1$s",
    MSG_HELP_COMMAND               = "Use \"/cs help <command>\" to show an explanation of the specified command.",
    -- 1: resource name
    MSG_DUPLICATE_RESOURCE         = "You already have a resource named \"%1$s\".",
    -- 1: resource name
    MSG_RESOURCE_DOESNT_EXIST      = "You do not have a resource named \"%1$s\".",
    -- 1: resource name, 2: min, 3: max
    MSG_RESOURCE_ALLOWED_VALUES    = "The resource %1$s must be in the range [%2$d, %3$d].",
    MSG_REQUIRE_RESOURCE_NAME      = "You must specify a resource name.",
    -- 1: resource name, 2: value
    MSG_RESOURCE_SET               = "%1$s set to %2$d.",
    -- 1: resource name
    MSG_RESOURCE_ADDED             = "Resource \"%1$s\" added.",
    MSG_RESOURCE_REMOVED           = "Resource removed.",
    MSG_INVALID_COLOR              = "You must specify a valid color.",
    MSG_NO_RESOURCE                = "You do not have a resource.",

    MSG_TRP_STATS_ARGS             = "The argument must be one of: off, cur, ooc",
    MSG_TRP_STATS_NONE             = "Your stats will now not appear in your TRP.",
    MSG_TRP_STATS_CURRENTLY        = "Your stats will now appear in your TRP Currently information.",
    MSG_TRP_STATS_OOC              = "Your stats will now appear in your TRP OOC information.",

    ERROR_PREFIX_UNAVAILABLE       = "The CharacterSheet addon could not register a message prefix. The addon may not work properly.",
    -- 1: save version, 2: current version
    ERROR_TIME_TRAVEL              = "Your CharacterSheet save file is from a newer version of the addon (%1$s) than the currently installed version (%2$s).\nMaybe something went wrong when updating the addon.",
    -- 1: command
    ERROR_DUPLICATE_COMMAND        = "Duplicate command name: %1$s",
    -- 1: command
    ERROR_PARSE_COMMAND_FAILED     = "Failed to parse command: %1$s",

    KEYBIND_HEADER                 = "Character Sheet",
    KEYBIND_INCREMENT_HP           = "Increment HP",
    KEYBIND_DECREMENT_HP           = "Decrement HP",
    KEYBIND_INCREMENT_PET_HP       = "Increment pet HP",
    KEYBIND_DECREMENT_PET_HP       = "Decrement pet HP",
    KEYBIND_TOGGLE_PET             = "Toggle pet",
    KEYBIND_TOGGLE_STATS_FRAME     = "Toggle stats frame",
    KEYBIND_TOGGLE_EDIT_FRAME      = "Toggle edit frame",

    SETTING_RAID_ROLLS             = "Raid Rolls",
    SETTING_RAID_ROLLS_DESC        = "When enabled and in a party or raid, the results of rolls with modifiers will be displayed in party/raid chat.",
    SETTING_TRP_STATS              = "TRP Stats",
    SETTING_TRP_STATS_DESC         = "When set to Currently or OOC, your stats and HP will automatically be put in front of your TRP Currently or OOC information respectively whenever they change.",
    SETTING_TRP_STATS_DISABLED     = "Disabled",
    SETTING_TRP_STATS_CURRENTLY    = "Currently",
    SETTING_TRP_STATS_OOC          = "OOC",

    -- 1: author, 2: title, 3: version
    ADDON_INFO                     = "%1$s's %2$s, version %3$s",

    CMD_DESC_HELP = multiline [[
        "/cs help" shows the list of commands.
        "/cs help <command>" shows an explanation of the specified command.
    ]],
    CMD_DESC_RAID_ROLLS = multiline [[
        "/cs raidrolls" toggles raid roll messages on and off.
    ]],
    CMD_DESC_VERSION = multiline [[
        "/cs version" shows the addon's current version number.
    ]],
    CMD_DESC_SET = multiline [[
        "/cs set <stat> <value>" sets the given stat to a given value.
        For example: "/cs set str 15"
    ]],
    CMD_DESC_ROLL = multiline [[
        "/cs roll <stat>" rolls with the given stat.
        "/cs roll <stat> <mod>" rolls with the given stat and an additional modifier.
        For example: "/cs roll str" or "/cs roll int 5" or "/cs roll cha -2"
    ]],
    CMD_DESC_STATS = multiline [[
        "/cs stats" shows the stats you have and their values.
    ]],
    CMD_DESC_HEAL = multiline [[
        "/cs heal" and "/cs heal combat" perform a heal roll using a d10.
        "/cs heal safe" performs a heal roll using a d14.
    ]],
    CMD_DESC_LEVEL = multiline [[
        "/cs level <level>" sets your character's power level to the specified level.
        <level> must be one of novice, apprentice, adept, expert, master.
    ]],
    CMD_DESC_VALIDATE = multiline [[
        "/cs validate" checks whether your stat block is valid.
    ]],
    CMD_DESC_HP = multiline [[
        "/cs hp max" sets your current HP to your max HP.
        "/cs hp <value>" sets your current HP to the given value.
    ]],
    CMD_DESC_PET = multiline [[
        "/cs pet" toggles your pet.
    ]],
    CMD_DESC_PETHP = multiline [[
        "/cs pethp max" sets your active pet's current HP to their max HP.
        "/cs pethp <value>" sets your active pet's current HP to the given value.
        "/cs pethp max <name>" sets the pet with the given name's current HP to their max HP.
        "/cs pethp <value> <name>" sets the pet with the given name's current HP to the given value.
    ]],
    CMD_DESC_PETATK = multiline [[
        "/cs petatk" performs a pet attack roll and displays the final damage number.
    ]],
    CMD_DESC_SETPETATK = multiline [[
        "/cs setpetatk <attribute>" sets your pet attack attribute to the given attribute.
    ]]

}
