local addon_name, CS = ...
local M = {}

M.Print = function(format, ...)
    SendSystemMessage(string.format(format, ...))
end

CS.Output = M
