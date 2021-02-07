--- Util module containing various utility functions.

local addon_name, CS = ...

local CS.Util = {}

--- Gets the matches with a pattern from a string.
-- @tparam string str The string to match against the pattern.
-- @tparam string pattern The pattern to match against.
-- @return Returns one string value for each match.
CS.Util.StrMatch = function(str, pattern)
    local tokens = {}
    for token in str:gmatch(pattern) do
        table.insert(tokens, token)
    end
    return unpack(tokens)
end
