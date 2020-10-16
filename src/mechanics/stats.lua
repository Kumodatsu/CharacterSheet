local addon_name, CS = ...
local M = {}

local Enum  = CS.Type.Enum
local Class = CS.Type.Class

M.AttributeNames = { "STR", "DEX", "CON", "INT", "WIS", "CHA" }

M.is_valid_attribute = function(name)
    for _, attrib in ipairs(M.AttributeNames) do
        if attrib == name then return true end
    end
    return false
end

M.StatMinVal = 5
M.StatMaxVal = 24

-- Enumeration of character power levels
M.PowerLevel = Enum {
    Novice     = 1,
    Apprentice = 2,
    Adept      = 3,
    Expert     = 4,
    Master     = 5
}

M.get_sp_bonus = function(level)
    return 14 + 2 * level
end

M.get_hp_bonus = function(level)
    return 2 * level
end

M.StatBlock = Class {
    STR   = 10,
    DEX   = 10,
    CON   = 10,
    INT   = 10,
    WIS   = 10,
    CHA   = 10,
    Level = M.PowerLevel.Adept,

    attributes = function(self)
        local index = 1
        return function()
            local attribute_name = M.AttributeNames[index]
            local value          = self[attribute_name]
            index = index + 1
            return attribute_name, value
        end
    end,

    -- Validates the stat block, checking if any constraints are violated.
    -- Returns two values.
    -- The first return value is true if the stat block is valid and false otherwise.
    -- The second return value is a message with information about invalid or suboptimal states.
    validate = function(self)
        for attrib, val in self:attributes() do
            if val < M.StatMinVal then
                return false,
                    "Attribute " .. attrib .. " can't be lower than " .. M.StatMinVal .. "."
            elseif val > M.StatMaxVal then
                return false,
                    "Attribute " .. attrib .. " can't be greater than " .. M.StatMaxVal .. "."
            end
        end
        local remaining_sp = self:get_remaining_sp()
        if remaining_sp < 0 then
            return false, "You have spent " .. -remaining_sp .. " too many SP."
        elseif remaining_sp > 0 then
            return true, "You still have " .. remaining_sp .. " unspent SP."
        end
        return true
    end,
    
    get_max_hp = function(self)
        return self.CON + M.get_hp_bonus(self.Level)
    end,

    get_pet_max_hp = function(self)
        return math.ceil(self:get_max_hp() / 2)
    end,

    -- The number of SP that may be spent given the power level.
    get_potential_sp = function(self)
        return 60 + M.get_sp_bonus(self.Level)
    end,

    -- The total number SP currently spent.
    get_total_sp = function(self)
        local total = 0
        for _, val in self:attributes() do
            total = total + val
        end
        return total
    end,

    -- The number of SP that may still be spent.
    get_remaining_sp = function(self)
        return self:get_potential_sp() - self:get_total_sp()
    end,

    -- The modifier to be added for healing rolls.
    get_heal_modifier = function(self)
        return math.floor(math.max(0, (self.CHA - 10)) / 2)
    end
}

CS.Stats = M
