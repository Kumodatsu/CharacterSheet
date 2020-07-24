local addon_name, cs = ...

-- Handle loading/saving of data from/to file
local on_addon_loaded = function()
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

local on_addon_unloading = function()
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

local frame_load_vars = CreateFrame("FRAME", "LoadData")

frame_load_vars:RegisterEvent("ADDON_LOADED")
frame_load_vars:RegisterEvent("PLAYER_LOGOUT")

frame_load_vars.OnEvent = function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addon_name then
        on_addon_loaded()
    elseif event == "PLAYER_LOGOUT" then
        on_addon_unloading()
    end
end

frame_load_vars:SetScript("OnEvent", frame_load_vars.OnEvent)
