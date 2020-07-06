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
    Master     = 5,

    get_sp_bonus = function(self)
        return 14 + 2 * self.Value
    end,

    get_hp_bonus = function(self)
        return 2 * self.Value
    end
}

M.StatBlock = Class {
    STR   = 10,
    DEX   = 10,
    CON   = 10,
    INT   = 10,
    WIS   = 10,
    CHA   = 10,
    Level = M.PowerLevel.Adept,

    get_max_hp = function(self)
        return self.CON + self.Level:get_hp_bonus()
    end
}

cs.Stats = M
