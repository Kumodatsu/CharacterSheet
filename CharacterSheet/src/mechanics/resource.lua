local addon_name, CS = ...
local M = {}

local T = CS.Locale.GetLocaleTranslations()

local Class = CS.Type.Class

M.Resource = Class {
    Name  = "Power",
    Value = 0,

    get_min = function()
        return 0
    end,

    get_max = function()
        return 0
    end
}

CS.Resource = M
