local addon_name, CS = ...
local M = {}

local Class = CS.Type.Class

M.Version = Class {
    Major = 0,
    Minor = 0,
    Patch = 0,

    __eq = function(a, b)
        return a.Major == b.Major
           and a.Minor == b.Minor
           and a.Patch == b.Patch 
    end,

    __lt = function(a, b)
        if a.Major > b.Major then return false end
        if a.Major < b.Major then return true end
        if a.Minor > b.Minor then return false end
        if a.Minor < b.Minor then return true end
        if a.Patch > b.Patch then return false end
        if a.Patch < b.Patch then return true end
        return false
    end,

    __tostring = function(self)
        return string.format("%d.%d.%d", self.Major, self.Minor, self.Patch)
    end
}

M.get_str = function()
    return GetAddOnMetadata(addon_name, "Version")
end

M.get = function()
    local str = get_str()
    return M.Version.from_str(str)
end

M.from_str = function(str)
    local major, minor, patch = CS.String.match(str, "%d+")
    return M.Version.new {
        Major = major,
        Minor = minor,
        Patch = patch
    }
end

CS.Version = M
