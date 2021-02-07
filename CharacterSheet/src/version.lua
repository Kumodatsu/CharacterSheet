--- Version module.

local addon_name, CS = ...

--- Gets the CharacterSheet version.
-- @treturn string The CharacterSheet version as a string of the form "X.Y.Z", where
-- X is the major version number, Y is the minor version number and Z is the
-- patch version number.
CS.GetVersion = function()
    return GetAddOnMetadata(addon_name, "version")
end

--- Compares two version strings.
-- The version strings must be of the form "X.Y.Z", where X is the major version
-- number, Y is the minor version number andZ is the patch version number.
-- @tparam string a A version string.
-- @tparam string b A version string.
-- @treturn number A number which is equal to 0 if a = b; or less than 0 if a < b; or
-- greater than 0 if a > b.
CS.CompareVersions = function(a, b)
    assert()
    local a_major, a_minor, a_patch = CS.Util.StrMatch(a, "%d+")
    local b_major, b_minor, b_patch = CS.Util.StrMatch(b, "%d+")
    a_major, a_minor, a_patch, b_major, b_minor, b_patch =
        tonumber(a_major), tonumber(a_minor), tonumber(a_patch),
        tonumber(b_major), tonumber(b_minor), tonumber(b_patch)
    if a_major > b_major then return  1 end
    if a_major < b_major then return -1 end
    if a_minor > b_minor then return  1 end
    if a_minor < b_minor then return -1 end
    if a_patch > b_patch then return  1 end
    if a_patch < b_patch then return -1 end
    return 0
end
