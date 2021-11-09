local _, CS = ...
local M = {}

-- t: table, s: num, e: num -> table
-- Returns the sublist of the list t starting at index s and ending at index e.
M.get_range = function(t, s, e)
    return { unpack(t, s, e) }
end

-- t: table, k: T -> bool
-- Returns true if the table t has a key k and the corresponding value is not
-- nil; returns false otherwise.
M.has_key = function(t, key)
    return t[key] ~= nil
end

M.has_value = function(t, value)
    for k, v in pairs(t) do
        if v == value then return true end
    end
    return false
end

M.is_empty = function(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end

M.get_keys = function(t)
    local ks = {}
    for k, _ in pairs(t) do
        table.insert(ks, k)
    end
    return ks
end

M.get_sorted_keys = function(t, sort)
    local ks = M.get_keys(t)
    table.sort(ks, sort)
    return ks
end

M.nearest_sorted = function(ks, v)
    local n = nil
    for i = 1, #ks do
        local k = ks[i]
        if v < k then
            return n
        end
        n = k
    end
    return n
end

M.nearest = function(ks, v)
    local r = { unpack(ks) }
    table.sort(r)
    return M.nearest_sorted(r, v)
end

M.map = function(t, f)
    local r = {}
    for k, v in pairs(t) do
        r[k] = f(v)
    end
    return r
end

M.metatable = function(t)
    setmetatable(t, t)
    return t
end

CS.Table = M
