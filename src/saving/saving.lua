local addon_name, CS = ...
local M = {}

local get_character_info = function()
    local name  = UnitName "player"
    local realm = GetRealmName()
    return realm, name
end

M.LoadVersions = {
    ["0.4.0"] = function()
        -- Addon settings
        CS.Roll.RaidRollsEnabled = CS_DB.RaidRollsEnabled or false
    end,
}

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
}

M.LoadData = function()
    local current_version = CS.Version.get_str()

    -- Character specific data
    do
        CS_Char_DB = CS_Char_DB or {
            Version = current_version
        }
        local version  = CS.Version.from_str(CS_Char_DB.Version)
        local versions = CS.Table.map(
            CS.Table.get_keys(M.LoadCharVersions),
            CS.Version.from_str
        )
        local load_version = CS.Table.nearest(versions, version)
        if load_version then
            M.LoadCharVersions[tostring(load_version)]()
        end
    end

    -- Account wide data
    do
        CS_DB = CS_DB or {
            Version = current_version
        }
        local version  = CS.Version.from_str(CS_DB.Version)
        local versions = CS.Table.map(
            CS.Table.get_keys(M.LoadVersions),
            CS.Version.from_str
        )
        local load_version = CS.Table.nearest(versions, version)
        if load_version then
            M.LoadVersions[tostring(load_version)]()
        end
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
