local addon_name, CS = ...
local M = {}

-- Handle loading/saving of data from/to file
M.LoadData = function()
    -- Account wide data
    CS_DB      = CS_DB      or {}
    -- Character specific data
    CS_Char_DB = CS_Char_DB or {}
    
    -- Detect outdated data formats
    local char_version = CS.Version.from_str(CS_Char_DB.Version)
    local old_trp      = char_version < CS.Version.from_str "0.4.2"

    -- Character stats
    CS.Charsheet.Stats     = CS.Stats.StatBlock.load(CS_Char_DB.Stats)
    CS.Charsheet.CurrentHP = CS_Char_DB.CurrentHP or CS.Charsheet.Stats:get_max_hp()
    CS.Charsheet.Pets      = CS_Char_DB.Pets      or {}
    CS.Charsheet.ActivePet = CS_Char_DB.ActivePet or CS.Charsheet.ActivePet

    -- Addon settings
    CS.Roll.RaidRollsEnabled = CS_DB.RaidRollsEnabled or false

    -- UI state
    CS.Interface.UIState = CS_Char_DB.UIState or CS.Interface.UIState

    -- TRP settings
    local ext_trp3 = CS.Extensions.totalRP3
    if ext_trp3 then
        local _TRP3_UpdateTRPWithStats = CS_Char_DB.TRP3_UpdateTRPWithStats
        -- Check if a value from an old version needs to be reinterpreted
        if old_trp and type(_TRP3_UpdateTRPWithStats) == "boolean" then
            _TRP3_UpdateTRPWithStats = _TRP3_UpdateTRPWithStats
                and ext_trp3.StatUpdateState.OOC
                or  ext_trp3.StatUpdateState.None
        end
        ext_trp3.UpdateTRPWithStats =
            _TRP3_UpdateTRPWithStats or
            ext_trp3.UpdateTRPWithStats
    end
end

M.SaveData = function()
    -- Version. Used to detect outdated data formats
    local version = CS.Version.get_str()
    CS_DB.Version      = version
    CS_Char_DB.Version = version

    -- Character stats
    CS_Char_DB.Stats     = CS.Charsheet.Stats:save()
    CS_Char_DB.CurrentHP = CS.Charsheet.CurrentHP
    CS_Char_DB.Pets      = CS.Charsheet.Pets
    CS_Char_DB.ActivePet = CS.Charsheet.ActivePet

    -- Addon settings
    CS_DB.RaidRollsEnabled = CS.Roll.RaidRollsEnabled

    -- UI state
    CS_Char_DB.UIState = CS.Interface.UIState

    -- TRP settings
    if CS.Extensions.totalRP3 then
        CS_Char_DB.TRP3_UpdateTRPWithStats =
            CS.Extensions.totalRP3.UpdateTRPWithStats
    end
end

CS.Saving = M
