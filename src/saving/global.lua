local addon_name, CS = ...
local M = CS.Saving

M.LoadVersions = {
    ["0.4.0"] = function()
        -- Addon settings
        CS.Roll.RaidRollsEnabled = CS_DB.RaidRollsEnabled or false
    end,
    ["0.4.3"] = function()
        -- Addon settings
        CS.Roll.RaidRollsEnabled = CS_DB.RaidRollsEnabled or false

        -- Character
        local realm, name = M.get_character_info()
        CS_DB.Characters              = CS_DB.Characters              or {}
        CS_DB.Characters[realm]       = CS_DB.Characters[realm]       or {}
        CS_DB.Characters[realm][name] = CS_DB.Characters[realm][name] or {}
        local char_db = CS_DB.Characters[realm][name] 

        -- Character stats
        CS.Charsheet.Stats     = CS.Stats.StatBlock.load(char_db.Stats)
        CS.Charsheet.CurrentHP = char_db.CurrentHP or CS.Charsheet.Stats:get_max_hp()
        CS.Charsheet.Pets      = char_db.Pets      or {}
        CS.Charsheet.ActivePet = char_db.ActivePet or CS.Charsheet.ActivePet
        
        -- UI state
        CS.Interface.UIState = char_db.UIState or CS.Interface.UIState

        -- TRP settings
        local ext_trp3 = CS.Extensions.totalRP3
        if ext_trp3 then
            ext_trp3.UpdateTRPWithStats =
                char_db.TRP3_UpdateTRPWithStats or
                ext_trp3.UpdateTRPWithStats
        end
    end
}
