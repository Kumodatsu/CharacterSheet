local _, CS = ...
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

CS.OnAddonLoaded          = M.create_event()
CS.OnAddonUnloading       = M.create_event()
CS.OnAddonMessageReceived = M.create_event()

CS.Event = M
