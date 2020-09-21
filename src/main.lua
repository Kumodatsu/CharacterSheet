local addon_name, CS = ...

-- Global addon accessor
CS_API = CS

-- Key bindings
BINDING_HEADER_CHARACTER_SHEET  = "Character Sheet"
BINDING_NAME_INCREMENT_HP       = "Increment HP"
BINDING_NAME_DECREMENT_HP       = "Decrement HP"
BINDING_NAME_TOGGLE_MAIN_FRAME  = "Toggle main frame"
BINDING_NAME_TOGGLE_STATS_FRAME = "Toggle stats frame"
BINDING_NAME_TOGGLE_EDIT_FRAME  = "Toggle edit frame"

-- Version command
local show_version = function()
    local author  = GetAddOnMetadata(addon_name, "author")
    local title   = GetAddOnMetadata(addon_name, "title")
    local version = GetAddOnMetadata(addon_name, "version")
    CS.Output.Print("%s's %s, version %s", author, title, version)
end

CS.Commands.add_cmd("version", show_version, [[
"/cs version" shows the addon's current version number.
]])
