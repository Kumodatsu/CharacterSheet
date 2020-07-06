local addon_name, cs = ...
local M = {}

local Enum  = cs.Type.Enum
local Class = cs.Type.Class
local print = print

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

    get_max_hp = function(self)
        return self.CON + M.get_hp_bonus(self.Level)
    end,
    end
}

cs.Stats = M
