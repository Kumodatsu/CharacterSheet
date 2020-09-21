local addon_name, CS = ...
local M = {}

-- Handle loading/saving of data from/to file
M.LoadData = function()
    -- Account wide data
    CS_DB      = CS_DB      or {}
    -- Character specific data
    CS_Char_DB = CS_Char_DB or {}
    
    -- Character stats
    CS.Charsheet.Stats     = CS.Stats.StatBlock.load(CS_Char_DB.Stats)
    CS.Charsheet.CurrentHP = CS_Char_DB.CurrentHP or CS.Charsheet.Stats:get_max_hp()
    CS.Charsheet.Pets      = CS_Char_DB.Pets      or {}

    -- Addon settings
    CS.Roll.RaidRollsEnabled = CS_DB.RaidRollsEnabled or false

    -- TRP settings
    if CS.Extensions.totalRP3 then
        CS.Extensions.totalRP3.UpdateTRPWithStats =
            CS_Char_DB.TRP3_UpdateTRPWithStats or false
    end
end

M.SaveData = function()
    -- Character stats
    CS_Char_DB.Stats     = CS.Charsheet.Stats:save()
    CS_Char_DB.CurrentHP = CS.Charsheet.CurrentHP
    CS_Char_DB.Pets      = CS.Charsheet.Pets

    -- Addon settings
    CS_DB.RaidRollsEnabled = CS.Roll.RaidRollsEnabled

    -- TRP settings
    if CS.Extensions.totalRP3 then
        CS_Char_DB.TRP3_UpdateTRPWithStats =
            CS.Extensions.totalRP3.UpdateTRPWithStats
    end
end

CS.Saving = M
