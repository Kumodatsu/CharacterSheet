local _, cs = ...
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

cs.OnAddonLoaded          = M.create_event()
cs.OnAddonUnloading       = M.create_event()
cs.OnAddonMessageReceived = M.create_event()

cs.Event = M
