local addon_name, CS = ...
CS.Event = {}

local M = CS.Event

local Event = {
    add    = function(self, callback)
        table.insert(self.callbacks, callback)
        return self
    end,
    __call = function(self, ...)
        for _, callback in pairs(self.callbacks) do
            callback(...)
        end
    end
}
Event.__index = Event

M.create_event = function()
    local event = { callbacks = {} }
    setmetatable(event, Event)
    return event
end

CS.Events = {
    OnAddonLoaded           = M.create_event(),
    AfterAddonLoaded        = M.create_event(),
    OnAddonUnloading        = M.create_event(),
    OnSystemMessageReceived = M.create_event(),
    OnAddonMessageReceived  = M.create_event(),
    OnRaidRosterUpdate      = M.create_event(),
    OnGroupRosterUpdate     = M.create_event(),
    OnNamePlateUnitAdded    = M.create_event(),
    OnNamePlateUnitRemoved  = M.create_event()
}

-- Event handling
local frame_events = CreateFrame("FRAME", "CS_EventFrame")

local event_names = {
    "ADDON_LOADED",
    "PLAYER_LOGIN",
    "PLAYER_LOGOUT",
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_ADDON"
    -- "RAID_ROSTER_UPDATE",
    -- "GROUP_ROSTER_UPDATE",
    -- "NAME_PLATE_UNIT_ADDED",
    -- "NAME_PLATE_UNIT_REMOVED"
}

for _, event_name in ipairs(event_names) do
    frame_events:RegisterEvent(event_name)
end

frame_events.OnEvent = function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == addon_name then
        CS.Storage.preprocess_data()
        CS.Storage.load_data()
        CS.Events.OnAddonLoaded()
    elseif event == "PLAYER_LOGIN" then
        CS.Events.AfterAddonLoaded()
    elseif event == "PLAYER_LOGOUT" then
        CS.Events.OnAddonUnloading()
        CS.Storage.save_data()
    elseif event == "CHAT_MSG_SYSTEM" then
        CS.Events.OnSystemMessageReceived(arg1)
    elseif event == "CHAT_MSG_ADDON" and CS_MessagePrefix
            and arg1 == CS_MessagePrefix then
        CS.Events.OnAddonMessageReceived(arg2, arg3, arg4)
    elseif event == "RAID_ROSTER_UPDATE" then
        CS.Events.OnRaidRosterUpdate()
    elseif event == "GROUP_ROSTER_UPDATE" then
        CS.Events.OnGroupRosterUpdate()
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        CS.Events.OnNamePlateUnitAdded(arg1)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        CS.Events.OnNamePlateUnitRemoved(arg1)
    end
end

frame_events:SetScript("OnEvent", frame_events.OnEvent)
