local _, cs = ...
local M = {}

M.Enum = function(enum)
    local mt = {
        from_string = enum.from_string or function(str)
            str = str:lower()
            for k, v in pairs(enum) do
                if k:lower() == str then
                    return v
                end
            end
            return nil
        end,

        to_string = enum.to_string or function(value)
            for k, v in pairs(enum) do
                if v == value then
                    return k
                end
            end
            return nil
        end
    }
    mt.__index = mt
    setmetatable(enum, mt)
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
