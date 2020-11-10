local addon_name, CS = ...
local M = {}

M.Event = {
    add       = function(self, callback)
        table.insert(self.callbacks, callback)
        return self
    end,
    __call    = function(self, ...)
        for _, callback in pairs(self.callbacks) do
            callback(...)
        end
    end
}
M.Event.__index = M.Event

M.create_event = function()
    local event = { callbacks = {} }
    setmetatable(event, M.Event)
    return event
end

CS.OnAddonLoaded           = M.create_event()
CS.OnAddonUnloading        = M.create_event()
CS.OnSystemMessageReceived = M.create_event()
CS.OnAddonMessageReceived  = M.create_event()
CS.OnRaidRosterUpdate      = M.create_event()
CS.OnGroupRosterUpdate     = M.create_event()
CS.OnNamePlateUnitAdded    = M.create_event()
CS.OnNamePlateUnitRemoved  = M.create_event()

-- Event handling
local frame_events = CreateFrame("FRAME", "CS_EventFrame")

local event_names = {
    "ADDON_LOADED",
    "PLAYER_LOGOUT",
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_ADDON",
    "RAID_ROSTER_UPDATE",
    "GROUP_ROSTER_UPDATE",
    "NAME_PLATE_UNIT_ADDED",
    "NAME_PLATE_UNIT_REMOVED"
}

for _, event_name in ipairs(event_names) do
    frame_events:RegisterEvent(event_name)
end

frame_events.OnEvent = function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == addon_name then
        CS.SavedData.preprocess_data()
        CS.SavedData.load_data()
        -- CS.Saving.LoadData()
        CS.OnAddonLoaded()
    elseif event == "PLAYER_LOGOUT" then
        CS.OnAddonUnloading()
        CS.SavedData.save_data()
        -- CS.Saving.SaveData()
    elseif event == "CHAT_MSG_SYSTEM" then
        CS.OnSystemMessageReceived(arg1)
    elseif event == "CHAT_MSG_ADDON" and arg1 == CS_MessagePrefix then
        CS.OnAddonMessageReceived(arg2, arg3, arg4)
    elseif event == "RAID_ROSTER_UPDATE" then
        CS.OnRaidRosterUpdate()
    elseif event == "GROUP_ROSTER_UPDATE" then
        CS.OnGroupRosterUpdate()
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        CS.OnNamePlateUnitAdded(arg1)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        CS.OnNamePlateUnitRemoved(arg1)
    end
end

frame_events:SetScript("OnEvent", frame_events.OnEvent)

CS.Event = M
