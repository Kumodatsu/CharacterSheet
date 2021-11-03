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

    local success, msg = M.Sheet:set_stat(attribute, value)
    CS.Print(success and T.MSG_STAT_SET(attribute, value) or msg)
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
    local resource = M.Sheet.Resource
    if resource then
        CS.Print(
            "%s: %d/%d",
            resource.Name,
            resource.Value,
            resource.Max
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
    CS.Print(T.MSG_POWER_LEVEL_SET(
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
        if not CS.Math.is_integer(value) then
            return CS.Print(T.MSG_SET_HP_ALLOWED_VALUES)
        end
    end
    
    local success, msg = M.Sheet:set_hp(value)
    CS.Print(success and T.MSG_HP_SET(value) or msg)
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
        if not CS.Math.is_integer(value) then
            return CS.Print(T.MSG_SET_PET_HP_ALLOWED_VALUES)
        end
    end

    local success, msg = M.Sheet:set_pet_hp(value)
    CS.Print(success and T.MSG_PET_HP_SET("Pet", value) or msg)
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

local colors = {
    ["red"]       = { 1.0, 0.0,  0.0, 1.0 },
    ["green"]     = { 0.0, 1.0,  0.0, 1.0 },
    ["blue"]      = { 0.0, 0.0,  1.0, 1.0 },
    ["yellow"]    = { 1.0, 1.0,  0.0, 1.0 },
    ["cyan"]      = { 0.0, 1.0,  1.0, 1.0 },
    ["magenta"]   = { 1.0, 0.0,  1.0, 1.0 },
    ["white"]     = { 1.0, 1.0,  1.0, 1.0 },
    ["black"]     = { 0.0, 0.0,  0.0, 1.0 },
    ["grey"]      = { 0.5, 0.5,  0.5, 1.0 },
    ["gray"]      = { 0.5, 0.5,  0.5, 1.0 },
    ["lightblue"] = { 0.1, 0.3,  0.9, 1.0 },
    ["purple"]    = { 0.5, 0.0,  0.5, 1.0 },
    ["orange"]    = { 1.0, 0.65, 0.0, 1.0 },
}

local cmd_addresource = function(name, min, max, color, text_color)
    -- Check if a name is specified
    if not name then
        return CS.Print(T.MSG_REQUIRE_RESOURCE_NAME)
    end
    -- Check if the given values are valid
    min = tonumber(min)
    max = tonumber(max)
    if not min or not max then
        return CS.Print(T.MSG_REQUIRE_VALUE)
    end
    -- Check if the given color is valid
    if color then
        color = colors[color]
        if not color then
            return CS.Print(T.MSG_INVALID_COLOR)
        end
    else
        color = colors["lightblue"]
    end
    if text_color then
        text_color = colors[text_color]
        if not text_color then
            return CS.Print(T.MSG_INVALID_COLOR)
        end
    else
        text_color = colors["white"]
    end

    local success, msg = M.Sheet:add_resource(name, min, max, color,
        text_color)
    CS.Print(success and T.MSG_RESOURCE_ADDED(name) or msg)
end

local cmd_removeresource = function()
    local success, msg = M.Sheet:remove_resource()
    CS.Print(success and T.MSG_RESOURCE_REMOVED or msg)
end

local cmd_setresource = function(value)
    -- Check if the given value is valid
    value = tonumber(value)
    if not value then
        return CS.Print(T.MSG_REQUIRE_VALUE)
    end

    local success, msg = M.Sheet:set_resource(value)
    CS.Print(success and T.MSG_RESOURCE_SET(M.Sheet.Resource.Name, value)
        or msg)
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

CS.Commands.add_cmd("addresource", cmd_addresource, [[
"/cs addresource <name> <min> <max> <color> <textcolor>" adds a resource with the given name and minimum and maximum values. If colors are specified, the UI bar will use those.
]])

CS.Commands.add_cmd("removeresource", cmd_removeresource, [[
"/cs removeresource" removes your resource if it exists.
]])

CS.Commands.add_cmd("setresource", cmd_setresource, [[
"/cs setresource <value>" sets your resource to the specified value. 
]])

CS.Mechanics = M
