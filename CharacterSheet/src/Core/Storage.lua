local addon_name, CS = ...
CS.Storage = {}

local M = CS.Storage

local T = CS.Locale.GetLocaleTranslations()

local do_load = true
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
    end },
    { "0.5.3", function()
        CS_DB.Sheets = nil
        for realm, characters in pairs(CS_DB.Characters) do
            for character, char_db in pairs(characters) do
                char_db.UIState = nil

                char_db.Sheet.StatBlock = char_db.Sheet.Stats
                char_db.Sheet.Stats     = nil
            end
        end
    end }
}

-- Preprocesses the save data to ensure it is in the latest expected format.
M.preprocess_data = function()
    CS_DB = CS_DB or {}
    local compare         = CS.Util.compare_versions
    local current_version = GetAddOnMetadata(addon_name, "Version")
    -- There is no compatability with saves made before version 0.4.8.
    if not CS_DB.Version or compare(CS_DB.Version, "0.4.8") < 0 then
        CS_DB = { Version = "0.0.0" }
    end
    if compare(CS_DB.Version, current_version) < 0 then
        -- If the current addon version is newer than the save data's version,
        -- incrementally update the save file for each version where a format
        -- change happened.
        for _, change in ipairs(format_changes) do
            if compare(CS_DB.Version, change[1]) < 0 then
                CS_DB.Version = change[1]
                change[2]()
            end
        end
    elseif compare(CS_DB.Version, current_version) > 0 then
        -- If the current addon version is older than the save data's version,
        -- one probably accidentally installed an older version while trying to
        -- update. In this case the save file is left unchanged to prevent loss
        -- of data.
        do_load = false
        do_save = false
        return message(T.ERROR_TIME_TRAVEL(CS_DB.Version, current_version))
    end
end

-- Load the saved data. The data is assumed to be in the latest expected format.
M.load_data = function()
    if not do_load then return end

    -- Global settings
    local R = CS.Mechanics.Roll
    R.Settings.raid_rolls_enabled = CS_DB.GlobalSettings.RaidRollsEnabled
        or R.Settings.raid_rolls_enabled

    -- Character
    local realm, character = M.get_character_info()
    CS_DB.Characters[realm] = CS_DB.Characters[realm] or {}
    CS_DB.Characters[realm][character] =
        CS_DB.Characters[realm][character] or {}
    local char_db = CS_DB.Characters[realm][character]
    char_db.Settings = char_db.Settings or {}

    -- Character sheet
    if char_db.Sheet then
        CS.State.Sheet.set_character_sheet(char_db.Sheet)
    end

    --[[ TRP3 settings
    local ext_trp3 = CS.Extensions.totalRP3
    if ext_trp3 then
        ext_trp3.UpdateTRPWithStats = char_db.Settings.TRP3_UpdateTRPWithStats
            or ext_trp3.UpdateTRPWithStats
    end
    ]]
end

-- Save data to the save file in the latest format.
M.save_data = function()
    if not do_save then return end

    -- Version
    CS_DB.Version = GetAddOnMetadata(addon_name, "Version")

    -- Global settings
    CS_DB.GlobalSettings.RaidRollsEnabled =
        CS.Mechanics.Roll.Settings.raid_rolls_enabled

    -- Character
    local realm, character = M.get_character_info()
    CS_DB.Characters[realm] = CS_DB.Characters[realm] or {}
    CS_DB.Characters[realm][character] =
        CS_DB.Characters[realm][character] or {}
    local char_db = CS_DB.Characters[realm][character]

    -- Character sheet
    char_db.Sheet = CS.State.Sheet.get_character_sheet()

    --[[ TRP3 settings
    local ext_trp3 = CS.Extensions.totalRP3
    if ext_trp3 then
        char_db.Settings.TRP3_UpdateTRPWithStats = ext_trp3.UpdateTRPWithStats
    end
    ]]
end
