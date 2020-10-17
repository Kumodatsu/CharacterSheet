local addon_name, CS = ...

local T = CS.Locale.GetLocaleTranslations()

-- Global addon accessor
CS_API = CS

-- Key bindings
BINDING_HEADER_CHARACTER_SHEET  = T.KEYBIND_HEADER
BINDING_NAME_INCREMENT_HP       = T.KEYBIND_INCREMENT_HP
BINDING_NAME_DECREMENT_HP       = T.KEYBIND_DECREMENT_HP
BINDING_NAME_TOGGLE_MAIN_FRAME  = T.KEYBIND_TOGGLE_MAIN_FRAME
BINDING_NAME_TOGGLE_STATS_FRAME = T.KEYBIND_TOGGLE_STATS_FRAME
BINDING_NAME_TOGGLE_EDIT_FRAME  = T.KEYBIND_TOGGLE_EDIT_FRAME

-- Version command
local show_version = function()
    local author  = GetAddOnMetadata(addon_name, "author")
    local title   = GetAddOnMetadata(addon_name, "title")
    local version = GetAddOnMetadata(addon_name, "version")
    CS.Output.Print(T.ADDON_INFO(author, title, version))
end

CS.Commands.add_cmd("version", show_version, [[
"/cs version" shows the addon's current version number.
]])
