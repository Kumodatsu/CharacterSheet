local addon_name, CS = ...
local M = {}

M.round = function(x)
    return math.floor(x + 0.5)
end

CS.Math = M
