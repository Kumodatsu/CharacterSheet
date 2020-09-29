local addon_name, CS = ...

CS.id = function(x)
    return x
end

CS.fwd = function(f, ...)
    local args = { ... }
    return function()
        return f(unpack(args))
    end
end
