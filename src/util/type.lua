local _, cs = ...
local M = {}

M.Enum = function(t)
    local mt   = {}
    local enum = {}
    mt.__index = mt
    for k, v in pairs(t) do
        if type(v) == "function" then
            mt[k] = v
        else
            enum[k] = { Value = v }
            setmetatable(enum[k], mt)
        end
    end
    return enum
end

M.Class = function(class)
    class.__index = class
    -- For saving to a saved variable
    class.save = class.save or function(self)
        local savedata = {}
        for k, v in pairs(self) do
            if type(v) ~= "function" then
                savedata[k] = v
            end
        end
        return savedata
    end
    local constructor = function(o)
        setmetatable(o, class)
        return o
    end
    return {
        -- Function for instantiating the class
        new = constructor,
        -- For loading from a saved variable
        load = function(savedata)
            savedata = savedata or {}
            return constructor(savedata)
        end
    }
end

cs.Type = M
