local addon_name, CS = ...
CS.Util = {}

local M = CS.Util

M.iformat = function(format, ...)
    local args, order = { ... }, {}
    format = format:gsub("%%(%d+)%$", function(i)
        table.insert(order, args[tonumber(i)])
        return "%"
    end)
    return string.format(format, unpack(order))
end

M.multiline = function(str)
    return str:gsub("^%s*", ""):gsub("\n%s*", "\n")
end
