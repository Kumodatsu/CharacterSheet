local addon_name, CS = ...
local M = {}

M.match = function(str, pattern)
    t = {}
    for m in str:gmatch(pattern) do
        table.insert(t, m)
    end
    return unpack(t)
end

M.iformat = function(format, ...)
    local args, order = { ... }, {}
    format = format:gsub("%%(%d+)%$", function(i)
        table.insert(order, args[tonumber(i)])
        return "%"
    end)
    return string.format(format, unpack(order))
end

CS.String = M
