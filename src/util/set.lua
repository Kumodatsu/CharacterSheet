local _, cs = ...
local M = {}

local Class = cs.Type.Class

M.Set = function(values)
    local set = {}
    for _, value in ipairs(values) do
        set[value] = true
    end
    return set
end

M.Add = function(set, value)
    set[value] = true
end

M.Contains = function(set, value)
    return set[value]
end

M.Remove = function(set, value)
    if M.Contains(set, value) then
        set[value] = nil
        return true
    end
    return false
end

cs.Set = M
