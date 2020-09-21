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

-- Event handling
local frame_events = CreateFrame("FRAME", "CS_EventFrame")

frame_events:RegisterEvent "ADDON_LOADED"
frame_events:RegisterEvent "PLAYER_LOGOUT"
frame_events:RegisterEvent "CHAT_MSG_ADDON"

frame_events.OnEvent = function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == addon_name then
        CS.Saving.LoadData()
        CS.OnAddonLoaded()
    elseif event == "PLAYER_LOGOUT" then
        CS.OnAddonUnloading()
        CS.Saving.SaveData()
    elseif event == "CHAT_MSG_ADDON" and arg1 == CS_MessagePrefix then
        CS.OnAddonMessageReceived(arg2, arg3, arg4)
    end
end

frame_events:SetScript("OnEvent", frame_events.OnEvent)
