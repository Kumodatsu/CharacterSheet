local addon_name, CS = ...

CS.Print = function(format, ...)
    SendSystemMessage(string.format(format, ...))
end
