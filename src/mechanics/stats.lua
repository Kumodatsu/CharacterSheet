local addon_name, cs = ...
local M = {}

local Enum  = cs.Type.Enum
local Class = cs.Type.Class
local print = print

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
        local attribute_names = { "STR", "DEX", "CON", "INT", "WIS", "CHA" }
        local index = 1
        return function()
            local attribute_name = attribute_names[index]
            local value          = self[attribute_name]
            index = index + 1
            return attribute_name, value
        end
    end,

    -- Validates the stat block, checking if any constraints are violated.
    -- Returns true if the stat block is valid.
    -- Returns false and an error (string) if the stat block is invalid.
    validate = function(self)
        local total = 0
        for attrib, val in self:attributes() do
            if val < M.StatMinVal then
                return false,
                    "Attribute " .. attrib .. " can't be lower than " .. M.StatMinVal .. "."
            elseif val > M.StatMaxVal then
                return false,
                    "Attribute " .. attrib .. " can't be greater than " .. M.StatMaxVal .. "."
            end
            total = total + val
        end
        local remaining_sp = self:get_potential_sp() - total
        if remaining_sp < 0 then
            return false, "You have spent " .. remaining_sp .. " too many SP."
        elseif remaining_sp > 0 then
            return false, "You still have " .. remaining_sp .. " unspent SP."
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

    -- The modifier to be added for healing rolls.
    get_heal_modifier = function(self)
        return math.floor(math.max(0, (self.CHA - 10)) / 2)
    end
}

cs.Stats = M
