local addon_name, CS = ...
local M = {}

M.get_character_info = function()
    local name  = UnitName "player"
    local realm = GetRealmName()
    return realm, name
end

M.SaveData = function()
    -- Version. Used to detect outdated data formats
    local version = CS.Version.get_str()
    CS_DB.Version = version
    CS_Char_DB = { Version = version } -- Needed for backwards compatability

    -- Character
    local realm, name = M.get_character_info()
    CS_DB.Characters              = CS_DB.Characters              or {}
    CS_DB.Characters[realm]       = CS_DB.Characters[realm]       or {}
    CS_DB.Characters[realm][name] = CS_DB.Characters[realm][name] or {}
    local char_db = CS_DB.Characters[realm][name]

    -- Character stats
    char_db.Stats     = CS.Charsheet.Stats:save()
    char_db.CurrentHP = CS.Charsheet.CurrentHP
    char_db.Pets      = CS.Charsheet.Pets
    char_db.ActivePet = CS.Charsheet.ActivePet

    -- Addon settings
    CS_DB.RaidRollsEnabled = CS.Roll.RaidRollsEnabled

    -- UI state
    char_db.UIState = CS.Interface.UIState

    -- TRP settings
    if CS.Extensions.totalRP3 then
        char_db.TRP3_UpdateTRPWithStats =
            CS.Extensions.totalRP3.UpdateTRPWithStats
    end
end

CS.Saving = M
