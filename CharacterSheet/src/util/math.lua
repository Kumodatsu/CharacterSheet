local addon_name, CS = ...
local M = {}

M.round = function(x)
    return math.floor(x + 0.5)
end

M.half = function(x, mode)
    x = tonumber(x)
    mode = mode or "up"
    mode = mode:lower()
    local half_x = x / 2
    if mode == "up" then
        return math.ceil(half_x)
    elseif mode == "down" then
        return math.floor(half_x)
    end
    return nil
end

M.is_integer = function(x)
    return math.floor(x) == x
end

CS.Math = M
