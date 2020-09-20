local addon_name, cs = ...

-- Global addon getter
CS_GetAddon = function()
    return cs
end

-- Key bindings
BINDING_HEADER_CHARACTER_SHEET  = "Character Sheet"
BINDING_NAME_INCREMENT_HP       = "Increment HP"
BINDING_NAME_DECREMENT_HP       = "Decrement HP"
BINDING_NAME_TOGGLE_MAIN_FRAME  = "Toggle main frame"
BINDING_NAME_TOGGLE_STATS_FRAME = "Toggle stats frame"
BINDING_NAME_TOGGLE_EDIT_FRAME  = "Toggle edit frame"

-- Addon messages
CS_MessagePrefix = "CS"
local request_result =
    C_ChatInfo.RegisterAddonMessagePrefix(CS_MessagePrefix)
if not request_result then
    message("The CharacterSheet addon could not register a message prefix. The addon may not work properly.")
end

-- Version command
local show_version = function()
    local author  = GetAddOnMetadata(addon_name, "author")
    local title   = GetAddOnMetadata(addon_name, "title")
    local version = GetAddOnMetadata(addon_name, "version")
    cs.Output.Print("%s's %s, version %s", author, title, version)
end

cs.Commands.add_cmd("version", show_version, [[
"/cs version" shows the addon's current version number.
]])

-- Event handling
local frame_events = CreateFrame("FRAME", "CS_EventFrame")

frame_events:RegisterEvent("ADDON_LOADED")
frame_events:RegisterEvent("PLAYER_LOGOUT")

frame_events.OnEvent = function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addon_name then
        cs.Saving.LoadData()
        cs.OnAddonLoaded()
    elseif event == "PLAYER_LOGOUT" then
        cs.OnAddonUnloading()
        cs.Saving.SaveData()
    end
end

frame_events:SetScript("OnEvent", frame_events.OnEvent)
