local addon_name, CS = ...
CS.State = CS.State or {}
CS.State.Sheet = {}

local M = CS.State.Sheet
local S = CS.Mechanics.Stats

local T = CS.Locale.GetLocaleTranslations()

local _, current_character_sheet = CS.Mechanics.Stats.create_character_sheet()

M.get_character_sheet = function()
    return current_character_sheet
end

local cmd_set = function(attribute, value)
    -- Check if the given attribute is valid
    if not attribute then
        return CS.print(T.MSG_REQUIRE_VALID_ATTRIBUTE)
    end
    attribute = attribute:upper()
    if not S.is_valid_attribute(attribute) then
        return CS.print(T.MSG_INVALID_STAT(attribute))
    end
    -- Check if the given value is valid
    value = tonumber(value)
    if not value then
        return CS.print(T.MSG_REQUIRE_VALUE)
    end

    local sheet = M.get_character_sheet()
    local success, msg = S.set_stat(sheet, attribute, value)
    CS.print(success and T.MSG_STAT_SET(attribute, value) or msg)
end

local cmd_roll = function(attribute, mod)
    -- Check if the attribute, if given, is valid
    attribute = attribute and attribute:upper() or nil
    if attribute and not S.is_valid_attribute(attribute) then
        return CS.print(T.MSG_INVALID_STAT(attribute))
    end
    -- Check if the modifier, if given, is a valid number
    local mod_n = tonumber(mod)
    if mod and not mod_n then
        return CS.print(T.MSG_INTEGER)
    end

    local sheet = M.get_character_sheet()
    S.roll_stat(sheet, attribute, mod_n)
end

local cmd_stats = function()
    local sheet = M.get_character_sheet()
    CS.print(
        "%s: %s",
        T.POWER_LEVEL,
        S.power_level_name(sheet.StatBlock.Level)
    )
    CS.print(
        "%s: %d/%d",
        T.HP,
        sheet.HP,
        S.get_max_hp(sheet.StatBlock)
    )
    if sheet.PetActive then
        CS.print(
            "%s %s: %d/%d",
            T.PET,
            T.HP,
            sheet.PetHP,
            S.get_pet_max_hp(sheet.StatBlock)
        )
    end
    CS.print("%s: %d", T.STR, sheet.StatBlock.STR)
    CS.print("%s: %d", T.DEX, sheet.StatBlock.DEX)
    CS.print("%s: %d", T.CON, sheet.StatBlock.CON)
    CS.print("%s: %d", T.INT, sheet.StatBlock.INT)
    CS.print("%s: %d", T.WIS, sheet.StatBlock.WIS)
    CS.print("%s: %d", T.CHA, sheet.StatBlock.CHA)
end

local cmd_heal = function(in_combat)
    in_combat = in_combat and in_combat:lower() or "combat"
    if in_combat == "combat" then
        in_combat = true
    elseif in_combat == "safe" then
        in_combat = false
    else
        return CS.print(T.MSG_ALLOWED_PARAMETERS("combat, safe"))
    end

    local sheet = M.get_character_sheet()
    S.roll_heal(sheet, in_combat)
end

local cmd_level = function(level)
    if not level then
        return CS.print(T.MSG_REQUIRE_VALUE)
    end
    level = S.power_level_from_name(level)
    if not level then
        return CS.print(T.MSG_ALLOWED_PARAMETERS(
            "novice, apprentice, adept, expert, master"
        ))
    end

    local sheet = M.get_character_sheet()
    S.set_level(sheet, level)
    CS.print(T.MSG_POWER_LEVEL_SET(
        S.power_level_name(level)
    ))
end

local cmd_validate = function()
    local sheet = M.get_character_sheet()
    local valid, msg = S.validate(sheet.StatBlock)
    CS.print(msg or T.MSG_VALID_STAT_BLOCK)
end

local cmd_hp = function(hp)
    if not hp then
        return CS.print(T.MSG_REQUIRE_VALUE)
    end
    local sheet = M.get_character_sheet()
    if hp == "max" then
        hp = S.get_max_hp(sheet.StatBlock)
    else
        hp = tonumber(hp)
        if not hp then
            return CS.print(T.MSG_SET_HP_ALLOWED_PARAMETERS)
        end
        if not CS.Util.is_integer(hp) then
            return CS.print(T.MSG_SET_HP_ALLOWED_VALUES)
        end
    end
    
    local success, msg = S.set_hp(sheet, hp)
    CS.print(success and T.MSG_HP_SET(hp) or msg)
end

local cmd_pet = function()
    local sheet = M.get_character_sheet()
    S.toggle_pet(sheet)
end

local cmd_pethp = function(value)
    if not value then
        return CS.print(T.MSG_REQUIRE_VALUE)
    end
    local sheet = M.get_character_sheet()
    if value == "max" then
        value = S.get_pet_max_hp(sheet.StatBlock)
    else
        value = tonumber(value)
        if not value then
            return CS.print(T.MSG_SET_HP_ALLOWED_PARAMETERS)
        end
        if not CS.Util.is_integer(value) then
            return CS.print(T.MSG_SET_PET_HP_ALLOWED_VALUES)
        end
    end

    local success, msg = S.set_pet_hp(sheet, value)
    CS.print(success and T.MSG_PET_HP_SET(value) or msg)
end

local cmd_petatk = function()
    local sheet = M.get_character_sheet()
    S.roll_pet_attack(sheet)
end

local cmd_setpetatk = function(attribute)
    if not attribute then
        return CS.print(T.MSG_REQUIRE_VALID_ATTRIBUTE)
    end
    attribute = attribute:upper()
    if not S.is_valid_attribute(attribute) then
        return CS.print(T.MSG_REQUIRE_VALID_ATTRIBUTE)
    end

    local sheet = M.get_character_sheet()
    S.set_pet_attribute(sheet, attribute)
    CS.print(T.MSG_PET_ATK_SET(attribute))
end

CS.Command.add_cmd("set",       cmd_set,       T.CMD_DESC_SET)
CS.Command.add_cmd("roll",      cmd_roll,      T.CMD_DESC_ROLL)
CS.Command.add_cmd("stats",     cmd_stats,     T.CMD_DESC_STATS)
CS.Command.add_cmd("heal",      cmd_heal,      T.CMD_DESC_HEAL)
CS.Command.add_cmd("level",     cmd_level,     T.CMD_DESC_LEVEL)
CS.Command.add_cmd("validate",  cmd_validate,  T.CMD_DESC_VALIDATE)
CS.Command.add_cmd("hp",        cmd_hp,        T.CMD_DESC_HP)
CS.Command.add_cmd("pet",       cmd_pet,       T.CMD_DESC_PET)
CS.Command.add_cmd("pethp",     cmd_pethp,     T.CMD_DESC_PETHP)
CS.Command.add_cmd("petatk",    cmd_petatk,    T.CMD_DESC_PETATK)
CS.Command.add_cmd("setpetatk", cmd_setpetatk, T.CMD_DESC_SETPETATK)
