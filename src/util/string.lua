local addon_name, CS = ...
local M = {}

M.match = function(str, pattern)
    t = {}
    for m in str:gmatch(pattern) do
        table.insert(t, m)
    end
    return unpack(t)
end

CS.String = M
