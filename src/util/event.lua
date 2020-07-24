local _, cs = ...
local M = {}

M.Event = {
    callbacks = {},
    add       = function(self, callback)
        table.insert(self.callbacks, callback)
    end,
    __call    = function(self)
        for _, callback in pairs(self.callbacks) do
            callback()
        end
    end
}
M.Event.__index = M.Event

M.create_event = function()
    local event = {}
    setmetatable(event, M.Event)
    return event
end

cs.Event = M
