local addon_name, cs = ...
local M = {}

M.Print = function(format, ...)
    SendSystemMessage(string.format(format, ...))
end

cs.Output = M
