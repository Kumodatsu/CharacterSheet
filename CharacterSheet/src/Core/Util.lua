local addon_name, CS = ...
CS.Util = {}

local M = CS.Util

M.match = function(str, pattern)
    local t = {}
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

M.multiline = function(str)
    return str:gsub("^%s*", ""):gsub("\n%s*", "\n")
end

M.compare_versions = function(a, b)
    local a_major, a_minor, a_patch = M.match(a, "%d+")
    local b_major, b_minor, b_patch = M.match(b, "%d+")
    if a_major > b_major then return  1 end
    if a_major < b_major then return -1 end
    if a_minor > b_minor then return  1 end
    if a_minor < b_minor then return -1 end
    if a_patch > b_patch then return  1 end
    if a_patch < b_patch then return -1 end
    return 0
end

M.is_integer = function(x)
    return math.floor(x) == x
end
