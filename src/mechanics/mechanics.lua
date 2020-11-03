local addon_name, CS = ...
local M = {}

local T = CS.Locale.GetLocaleTranslations()

M.Sheet = CS.CharacterSheet.CharacterSheet.new()

local cmd_set = function(attribute, value)
    -- Check if the given stat is valid
    if not attribute then
        return CS.Print(T.MSG_REQUIRE_VALID_ATTRIBUTE)
    end
    attribute = attribute:upper()
    if not CS.Stats.is_valid_attribute(attribute) then
        return CS.Print(T.MSG_INVALID_STAT(attribute))
    end
    -- Check if the given value is valid
    value = tonumber(value)
    if not value then
        return CS.Print(T.MSG_REQUIRE_VALUE)
    end
    if value < CS.Stats.StatMinVal or value > CS.Stats.StatMaxVal then
        return CS.Print(T.MSG_RANGE(CS.Stats.StatMinVal, CS.Stats.StatMaxVal))
    end

    M.Sheet:set_stat(attribute, value)
    CS.Output.Print(T.MSG_STAT_SET(attribute, value))
end

local cmd_roll = function(attribute, mod)
    -- Check if the stat, if given, is valid
    attribute = attribute and attribute:upper() or nil
    if attribute and not CS.Stats.is_valid_attribute(attribute) then
        return CS.Print(T.MSG_INVALID_STAT(attribute))
    end
    -- Check if the modifier, if given, is a valid number
    local mod_n = tonumber(mod)
    if mod and not mod_n then
        return CS.Print(T.MSG_INTEGER)
    end

    M.Sheet:roll_stat(attribute, mod_n)
end

local cmd_stats = function()
    CS.Print(
        "%s: %s",
        T.POWER_LEVEL,
        CS.Stats.PowerLevel.to_string(M.Sheet.Stats.Level)
    )
    CS.Print(
        "%s: %d/%d",
        T.HP,
        M.Sheet.HP,
        M.Sheet.Stats:get_max_hp()
    )
    if M.Sheet.PetActive then
        CS.Print(
            "%s %s: %d/%d",
            T.PET,
            T.HP,
            M.Sheet.PetHP,
            M.Sheet.Stats:get_pet_max_hp()
        )
    end
    CS.Print("%s: %d", T.STR, M.Sheet.Stats.STR)
    CS.Print("%s: %d", T.DEX, M.Sheet.Stats.DEX)
    CS.Print("%s: %d", T.CON, M.Sheet.Stats.CON)
    CS.Print("%s: %d", T.INT, M.Sheet.Stats.INT)
    CS.Print("%s: %d", T.WIS, M.Sheet.Stats.WIS)
    CS.Print("%s: %d", T.CHA, M.Sheet.Stats.CHA)
end

local cmd_heal = function(in_combat)
    in_combat = in_combat and in_combat:lower() or "combat"
    if in_combat == "combat" then
        in_combat = true
    elseif in_combat == "safe" then
        in_combat = false
    else
        return CS.Print(T.MSG_ALLOWED_PARAMETERS("combat, safe"))
    end

    M.Sheet:roll_heal(in_combat)
end

local cmd_level = function(level)
    if not level then
        return CS.Print(T.MSG_REQUIRE_VALUE)
    end
    level = CS.Stats.PowerLevel.from_string(level)
    if not level then
        return T.MSG_ALLOWED_PARAMETERS(
            "novice, apprentice, adept, expert, master"
        )
    end

    M.Sheet:set_level(level)
    CS.Output.Print(T.MSG_POWER_LEVEL_SET(
        CS.Stats.PowerLevel.to_string(level)
    ))
end

local cmd_validate = function()
    local valid, msg = M.Sheet.Stats:validate()
    CS.Print(msg or T.MSG_VALID_STAT_BLOCK)
end

local cmd_hp = function(value)
    if not value then
        return CS.Print(T.MSG_REQUIRE_VALUE)
    end
    if value == "max" then
        value = M.Sheet.Stats:get_max_hp()
    else
        value = tonumber(value)
        if not value then
            return CS.Print(T.MSG_SET_HP_ALLOWED_PARAMETERS)
        end
    end
    if value < 0 or value > M.Sheet.Stats:get_max_hp()
            or not CS.Math.is_integer(value) then
        return CS.Print(T.MSG_SET_HP_ALLOWED_VALUES)
    end

    M.Sheet:set_hp(value)
    CS.Output.Print(T.MSG_HP_SET(value))
end

local cmd_pet = function()
    M.Sheet:toggle_pet()
end

local cmd_pethp = function(value)
    if not value then
        return CS.Print(T.MSG_REQUIRE_VALUE)
    end
    if value == "max" then
        value = M.Sheet.Stats:get_pet_max_hp()
    else
        value = tonumber(value)
        if not value then
            return CS.Print(T.MSG_SET_HP_ALLOWED_PARAMETERS)
        end
    end
    if value < 0 or value > M.Sheet.Stats:get_pet_max_hp()
            or not CS.Math.is_integer(value) then
        return CS.Print(T.MSG_SET_PET_HP_ALLOWED_VALUES)
    end

    M.Sheet:set_pet_hp(value)
end

local cmd_petatk = function()
    M.Sheet:pet_attack()
end

local cmd_setpetatk = function(attribute)
    if not attribute then
        return CS.Print(T.MSG_REQUIRE_VALID_ATTRIBUTE)
    end
    attribute = attribute:upper()
    if not CS.Stats.is_valid_attribute(attribute) then
        return CS.Print(T.MSG_REQUIRE_VALID_ATTRIBUTE)
    end

    M.Sheet:set_pet_attribute(attribute)
    CS.Print(T.MSG_PET_ATK_SET(attribute))
end

CS.Commands.add_cmd("set", cmd_set, [[
"/cs set <stat> <value>" sets the given stat to a given value.
For example: "/cs set str 15"
]])

CS.Commands.add_cmd("roll", cmd_roll, [[
"/cs roll <stat>" rolls with the given stat.
"/cs roll <stat> <mod>" rolls with the given stat and an additional modifier.
For example: "/cs roll str" or "/cs roll int 5" or "/cs roll cha -2"
]])

CS.Commands.add_cmd("stats", cmd_stats, [[
"/cs stats" shows the stats you have and their values.
]])

CS.Commands.add_cmd("heal", cmd_heal, [[
"/cs heal" and "/cs heal combat" perform a heal roll using a d10.
"/cs heal safe" performs a heal roll using a d14.
]])

CS.Commands.add_cmd("level", cmd_level, [[
"/cs level <level>" sets your character's power level to the specified level.
<level> must be one of novice, apprentice, adept, expert, master.
]])

CS.Commands.add_cmd("validate", cmd_validate, [[
"/cs validate" checks whether your stat block is valid.
]])

CS.Commands.add_cmd("hp", cmd_hp, [[
"/cs hp max" sets your current HP to your max HP.
"/cs hp <value>" sets your current HP to the given value.
]])

CS.Commands.add_cmd("pet", cmd_pet, [[
"/cs pet" toggles your pet.
]])

CS.Commands.add_cmd("pethp", cmd_pethp, [[
"/cs pethp max" sets your active pet's current HP to their max HP.
"/cs pethp <value>" sets your active pet's current HP to the given value.
"/cs pethp max <name>" sets the pet with the given name's current HP to their max HP.
"/cs pethp <value> <name>" sets the pet with the given name's current HP to the given value.
]])

CS.Commands.add_cmd("petatk", cmd_petatk, [[
"/cs petatk" performs a pet attack roll and displays the final damage number.
]])

CS.Commands.add_cmd("setpetatk", cmd_setpetatk, [[
"/cs setpetatk <attribute>" sets your pet attack attribute to the given attribute.
]])

CS.Mechanics = M
