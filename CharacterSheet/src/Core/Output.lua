--- Functions for presenting output.
-- @module CS.Output

local addon_name, CS = ...

--[[--
    Prints a formatted string to the chat as a system message.
    This function formats strings in the same way as string.format.
    @tparam string format The format string.
    @param[optchain] ... The values to format the string with.
]]
CS.print = function(format, ...)
    SendSystemMessage(string.format(format, ...))
end
