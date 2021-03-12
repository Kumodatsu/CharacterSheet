local addon_name, CS = ...

CS.print = function(format, ...)
    SendSystemMessage(string.format(format, ...))
end
