local addon_name, CS = ...

CS.fwd = function(f, ...)
    local args = { ... }
    return function()
        return f(unpack(args))
    end
end
