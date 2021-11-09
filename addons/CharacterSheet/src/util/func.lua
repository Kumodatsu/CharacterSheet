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

CS.skip_arg = function(f)
    return function(arg)
        return f()
    end
end

CS.switch = function(v)
    return function(mapping)
        return v and mapping[v] or nil
    end
end

CS.switchf = function(v)
    return function(mapping)
        local r = v and mapping[v] or nil
        if type(r) == "function" then
            return r(v)
        end
        return r
    end
end
