local addon_name, CS = ...
local M = {}

M.compare = function(a, b)
    local a_major, a_minor, a_patch = CS.String.match(a, "%d+")
    local b_major, b_minor, b_patch = CS.String.match(b, "%d+")
    if a_major > b_major then return  1 end
    if a_major < b_major then return -1 end
    if a_minor > b_minor then return  1 end
    if a_minor < b_minor then return -1 end
    if a_patch > b_patch then return  1 end
    if a_patch < b_patch then return -1 end
    return 0
end

CS.Version = M
