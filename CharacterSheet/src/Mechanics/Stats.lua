local addon_name, CS = ...
CS.Mechanics = CS.Mechanics or {}
CS.Mechanics.Stats = {}

local M = CS.Mechanics.Stats

local T = CS.Locale.GetLocaleTranslations()

local RollType = CS.Mechanics.Roll.RollType

M.StatMinValue = 5
M.StatMaxValue = 24

M.PowerLevel = {
    Novice     = 1,
    Apprentice = 2,
    Adept      = 3,
    Expert     = 4,
    Master     = 5
}

M.AttributeNames = { "STR", "DEX", "CON", "INT", "WIS", "CHA" }

M.is_valid_attribute = function(name)
    for _, attrib in ipairs(M.AttributeNames) do
        if attrib == name then return true end
    end
    return false
end

M.get_sp_bonus = function(level)
    return 14 + 2 * level
end

M.get_hp_bonus = function(level)
    return 2 * level
end

M.create_stat_block = function(level, str, dex, con, int, wis, cha)
    return {
        STR   = str or 13,
        DEX   = dex or 13,
        CON   = con or 13,
        INT   = int or 13,
        WIS   = wis or 13,
        CHA   = cha or 13,
        Level = level or M.PowerLevel.Apprentice
    }
end

M.get_attributes = function(stat_block)
    local index = 1
    return function()
        local attribute_name = M.AttributeNames[index]
        local value          = stat_block[attribute_name]
        index = index + 1
        return attribute_name, value
    end
end

M.validate = function(stat_block)
    for attribute, value in M.get_attributes(stat_block) do
        if value < M.StatMinValue or value > M.StatMaxValue then
            return false, T.MSG_ATTRIB_RANGE(attribute, M.StatMinValue,
                M.StatMaxValue)
        end
    end
    local remaining_sp = M.get_remaining_sp(stat_block)
    if remaining_sp < 0 then
        return false, T.MSG_TOO_MANY_SP(-remaining_sp)
    elseif remaining_sp > 0 then
        return true, T.MSG_UNSPENT_SP(remaining_sp)
    end
    return true
end

M.get_max_hp = function(stat_block)
    return stat_block.CON + M.get_hp_bonus(stat_block.Level)
end

M.get_pet_max_hp = function(stat_block)
    return math.ceil(get_max_hp(stat_block) / 2)
end

M.get_potential_sp = function(stat_block)
    return 60 + M.get_sp_bonus(stat_block.Level)
end

M.get_total_sp = function(stat_block)
    local total = 0
    for _, value in M.get_attributes(stat_block) do
        total = total + value
    end
    return total
end

M.get_remaining_sp = function(stat_block)
    return M.get_potential_sp(stat_block) - M.get_total_sp(stat_block)
end

M.get_heal_modifier = function(stat_block)
    return math.floor(math.max(0, stat_block.CHA - 10) / 2)
end
