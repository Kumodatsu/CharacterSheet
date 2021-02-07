--- Functionality for handling version information.

local addon_name, CS = ...

--- Gets the CharacterSheet version.
-- @function CS_API.GetVersion
-- @treturn string The CharacterSheet version as a string of the form "X.Y.Z",
-- where X is the major version number, Y is the minor version number and Z is
-- the patch version number.
CS_API.GetVersion = CS.GetVersion

--- Compares two version strings.
-- The version strings must be of the form "X.Y.Z", where X is the major version
-- number, Y is the minor version number andZ is the patch version number.
-- @function CS_API.CompareVersions
-- @tparam string a A version string.
-- @tparam string b A version string.
-- @treturn number A number which is equal to 0 if a = b; or less than 0 if
-- a < b; or greater than 0 if a > b.
CS_API.CompareVersions = CS.CompareVersions
