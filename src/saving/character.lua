local addon_name, CS = ...
local M = CS.Saving

M.LoadCharVersions = {
    ["0.4.0"] = function()
        -- Character stats
        CS.Charsheet.Stats     = CS.Stats.StatBlock.load(CS_Char_DB.Stats)
        CS.Charsheet.CurrentHP = CS_Char_DB.CurrentHP or CS.Charsheet.Stats:get_max_hp()
        CS.Charsheet.Pets      = CS_Char_DB.Pets      or {}
        CS.Charsheet.ActivePet = CS_Char_DB.ActivePet or CS.Charsheet.ActivePet
        
        -- UI state
        CS.Interface.UIState = CS_Char_DB.UIState or CS.Interface.UIState

        -- TRP settings
        local ext_trp3 = CS.Extensions.totalRP3
        if ext_trp3 then
            local _TRP3_UpdateTRPWithStats = CS_Char_DB.TRP3_UpdateTRPWithStats
            if _TRP3_UpdateTRPWithStats then
                _TRP3_UpdateTRPWithStats = _TRP3_UpdateTRPWithStats
                    and ext_trp3.StatUpdateState.OOC
                    or  ext_trp3.StatUpdateState.None
            end
            ext_trp3.UpdateTRPWithStats =
                _TRP3_UpdateTRPWithStats or
                ext_trp3.UpdateTRPWithStats
        end
    end,
    ["0.4.2"] = function()
        -- Character stats
        CS.Charsheet.Stats     = CS.Stats.StatBlock.load(CS_Char_DB.Stats)
        CS.Charsheet.CurrentHP = CS_Char_DB.CurrentHP or CS.Charsheet.Stats:get_max_hp()
        CS.Charsheet.Pets      = CS_Char_DB.Pets      or {}
        CS.Charsheet.ActivePet = CS_Char_DB.ActivePet or CS.Charsheet.ActivePet
        
        -- UI state
        CS.Interface.UIState = CS_Char_DB.UIState or CS.Interface.UIState

        -- TRP settings
        local ext_trp3 = CS.Extensions.totalRP3
        if ext_trp3 then
            ext_trp3.UpdateTRPWithStats =
                CS_Char_DB.TRP3_UpdateTRPWithStats or
                ext_trp3.UpdateTRPWithStats
        end
    end,
    ["0.4.3"] = function()
        -- Character data has been moved to the account wide data file
    end
}
