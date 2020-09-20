local addon_name, cs = ...
local M = {}

-- Handle loading/saving of data from/to file
M.LoadData = function()
    -- Account wide data
    CS_DB      = CS_DB      or {}
    -- Character specific data
    CS_Char_DB = CS_Char_DB or {}
    
    -- Character stats
    cs.Charsheet.Stats     = cs.Stats.StatBlock.load(CS_Char_DB.Stats)
    cs.Charsheet.CurrentHP = CS_Char_DB.CurrentHP or cs.Charsheet.Stats:get_max_hp()
    cs.Charsheet.Pets      = CS_Char_DB.Pets      or {}

    -- Addon settings
    cs.Roll.RaidRollsEnabled = CS_DB.RaidRollsEnabled or false

    -- TRP settings
    if cs.Extensions.totalRP3 then
        cs.Extensions.totalRP3.UpdateTRPWithStats =
            CS_Char_DB.TRP3_UpdateTRPWithStats or false
    end
end

M.SaveData = function()
    -- Character stats
    CS_Char_DB.Stats     = cs.Charsheet.Stats:save()
    CS_Char_DB.CurrentHP = cs.Charsheet.CurrentHP
    CS_Char_DB.Pets      = cs.Charsheet.Pets

    -- Addon settings
    CS_DB.RaidRollsEnabled = cs.Roll.RaidRollsEnabled

    -- TRP settings
    if cs.Extensions.totalRP3 then
        CS_Char_DB.TRP3_UpdateTRPWithStats =
            cs.Extensions.totalRP3.UpdateTRPWithStats
    end
end

cs.Saving = M
