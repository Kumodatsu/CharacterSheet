--- Various utility functions.
-- @module CS.Util
-- @alias M

local addon_name, CS = ...
CS.Util = {}

local M = CS.Util

--[[--
    Gets the matches of a pattern in a string.
    @tparam string str The string to match on.
    @tparam string pattern The pattern string.
    @treturn {string,...} The matches.
]]
M.match = function(str, pattern)
    local t = {}
    for m in str:gmatch(pattern) do
        table.insert(t, m)
    end
    return unpack(t)
end

--[[--
    Formats a string with values in an order independent way.
    The format string may contain directives of the form %n$t where n is the
    index of the argument (not counting the format string itself) to insert in
    the directive's place, and t is a letter that indicates how to format the
    argument; the latter is the same as the standard string.format function. For
    example, the directive %2$d inserts the second argument as a decimal number.
    @tparam string format The format string.
    @param[optchain] ... The values to format the string with.
]]
M.iformat = function(format, ...)
    local args, order = { ... }, {}
    format = format:gsub("%%(%d+)%$", function(i)
        table.insert(order, args[tonumber(i)])
        return "%"
    end)
    return string.format(format, unpack(order))
end

--[[--
    Removes indentation and initial line breaks from a string.
    Removes all space and tab characters following line breaks, and all line
    breaks at the beginning of the string. This can be used to be able to format
    multiline strings in source code to fit the rest of the code, without the
    formatting affecting the actual string value.
    @tparam string str The string to process.
    @treturn string The processed string.
]]
M.multiline = function(str)
    return str:gsub("^%s*", ""):gsub("\n%s*", "\n")
end

--[[--
    Compares two version strings.
    Compares the two version strings and returns a value which indicates which
    version is later. The version strings must be of the format "x.y.z" where the
    numbers x, y and z are the major version, minor version and patch version
    respectively.
    @tparam string a The first version string.
    @tparam string b The second version string.
    @treturn number A number that is equal to 0 iff a = b, less than 0 iff a < b
    and greater than 0 iff a > b.
]]
M.compare_versions = function(a, b)
    local a_major, a_minor, a_patch = M.match(a, "%d+")
    local b_major, b_minor, b_patch = M.match(b, "%d+")
    if a_major > b_major then return  1 end
    if a_major < b_major then return -1 end
    if a_minor > b_minor then return  1 end
    if a_minor < b_minor then return -1 end
    if a_patch > b_patch then return  1 end
    if a_patch < b_patch then return -1 end
    return 0
end

--[[--
    Checks if a value is an integer.
    @tparam number x A numeric value.
    @treturn boolean true iff x is an integer (number without fractional part),
    false otherwise.
]]
M.is_integer = function(x)
    return math.floor(x) == x
end

--[[--
    Rounds a value to the nearest integer.
    @tparam number x A numeric value.
    @treturn number The integer value that is closest to x.
]]
M.round = function(x)
    return math.floor(x + 0.5)
end
