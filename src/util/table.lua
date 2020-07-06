local _, cs = ...
local M = {}

-- t: table, s: num, e: num -> table
-- Returns the sublist of the list t starting at index s and ending at index e.
M.get_range = function(t, s, e)
    return { unpack(t, s, e) }
end

-- t: table, k: T -> bool
-- Returns true if the table t has a key k and the corresponding value is not
-- nil; returns false otherwise.
M.has_key = function(t, k)
    return t[k] ~= nil
end

cs.Table = M
