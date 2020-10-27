local _, CS = ...
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
        end,

        match = enum.match or function(value)
            return function(mapping)
                return mapping[value]
            end
        end,

        matchf = enum.matchf or function(value)
           return function(mapping)
             local r = mapping[value]
             if type(r) == "function" then
               return r(value)
             end
             return r
           end
        end,

        is_value = enum.is_value or function(value)
            for k, v in pairs(enum) do
                if value == v then return true end
            end
            return false
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
        o = o or {}
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

CS.Type = M
