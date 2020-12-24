local addon_name, CS = ...
CS.SavedData = {}
local M = CS.SavedData

local T = CS.Locale.GetLocaleTranslations()

local release_page = "https://github.com/Kumodatsu/CharacterSheet/releases"

local do_save = true

-- Returns the current character's realm and name.
M.get_character_info = function()
    local name  = UnitName "player"
    local realm = GetRealmName()
    return realm, name
end

-- This table contains, for each version of the addon where the format of the
-- save file was changed, a function that transforms save data from the previous
-- format to the new format.
local format_changes = {
    { "0.4.8", function()
        CS_DB.Characters     = {}
        CS_DB.GlobalSettings = {}
        CS_DB.Sheets         = {}
    end }
}

-- Preprocesses the save data to ensure it is in the latest expected format.
M.preprocess_data = function()
    CS_DB = CS_DB or {}
    local current_version = GetAddOnMetadata(addon_name, "Version")
    -- There is no compatability with saves made before version 0.4.8.
    if not CS_DB.Version or CS.Version.compare(CS_DB.Version, "0.4.8") < 0 then
        CS_DB = { Version = "0.0.0" }
    end
    if CS.Version.compare(CS_DB.Version, current_version) < 0 then
        -- If the current addon version is newer than the save data's version,
        -- incrementally update the save file for each version where a format
        -- change happened.
        for _, change in ipairs(format_changes) do
            if CS.Version.compare(CS_DB.Version, change[1]) < 0 then
                CS_DB.Version = change[1]
                change[2]()
            end
        end
    elseif CS.Version.compare(CS_DB.Version, current_version) > 0 then
        -- If the current addon version is older than the save data's version,
        -- one probably accidentally installed an older version while trying to
        -- update. In this case the save file is left unchanged to prevent loss
        -- of data.
        do_save = false
        return message(T.ERROR_TIME_TRAVEL(CS_DB.Version, current_version,
            release_page))
    end
end

-- Load the saved data. The data is assumed to be in the latest expected format.
M.load_data = function()
    -- Global settings
    CS.Roll.RaidRollsEnabled = CS_DB.GlobalSettings.RaidRollsEnabled
        or CS.Roll.RaidRollsEnabled

    -- Character
    local realm, character = M.get_character_info()
    CS_DB.Characters[realm] = CS_DB.Characters[realm] or {}
    CS_DB.Characters[realm][character] =
        CS_DB.Characters[realm][character] or {}
    local char_db = CS_DB.Characters[realm][character]
    char_db.Settings = char_db.Settings or {}

    -- Character settings
    CS.Interface.UIState = char_db.UIState or CS.Interface.UIState

    -- Character sheet
    CS.Mechanics.Sheet = CS.CharacterSheet.CharacterSheet.load(char_db.Sheet)
    CS.Mechanics.Sheet.Stats = CS.Stats.StatBlock.load(CS.Mechanics.Sheet.Stats)

    -- TRP3 settings
    local ext_trp3 = CS.Extensions.totalRP3
    if ext_trp3 then
        ext_trp3.UpdateTRPWithStats = char_db.Settings.TRP3_UpdateTRPWithStats
            or ext_trp3.UpdateTRPWithStats
    end
end

-- Save data to the save file in the latest format.
M.save_data = function()
    if not do_save then return end

    -- Version
    CS_DB.Version = GetAddOnMetadata(addon_name, "Version")

    -- Global settings
    CS_DB.GlobalSettings.RaidRollsEnabled = CS.Roll.RaidRollsEnabled

    -- Character
    local realm, character = M.get_character_info()
    CS_DB.Characters[realm] = CS_DB.Characters[realm] or {}
    CS_DB.Characters[realm][character] =
        CS_DB.Characters[realm][character] or {}
    local char_db = CS_DB.Characters[realm][character]

    -- Character settings
    char_db.UIState = CS.Interface.UIState

    -- Character sheet
    char_db.Sheet       = CS.Mechanics.Sheet:save()
    char_db.Sheet.Stats = CS.Mechanics.Sheet.Stats:save()

    -- TRP3 settings
    local ext_trp3 = CS.Extensions.totalRP3
    if ext_trp3 then
        char_db.Settings.TRP3_UpdateTRPWithStats = ext_trp3.UpdateTRPWithStats
    end
end

