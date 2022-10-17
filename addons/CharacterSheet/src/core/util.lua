--- Generic utility functions for commonly used functionality.
-- @module Core.Util
local _, CS = ...
local M = {}

--- Prints a value or formatted message to the chat.
-- The format string is formatted using @{Core.Util.iformat|iformat} instead
-- of string.format.
-- @tparam any value_or_format
-- The value to be printed.
-- If this is a string, it will be formatted using the following arguments.
-- @param ...
-- Any number of values to be formatted into the format string.
function M.display(value_or_format, ...)
  if type(value_or_format) == "string" then
    print(M.iformat(value_or_format, ...))
  else
    print(tostring(value_or_format))
  end
end

--- Searches a string for a Lua pattern.
-- @tparam string str
-- The string to search.
-- @tparam string pattern
-- The pattern to match with.
-- @tparam ?function f
-- A function used to transform each match before adding it to the results.
-- If not supplied, the matches are returned unchanged.
-- @treturn table
-- A table containing all matched strings in order.
function M.match(str, pattern, f)
  f = f or function(x) return x end
  t = {}
  for m in str:gmatch(pattern) do
    table.insert(t, f(m))
  end
  return t
end

--- Formats a string.
-- This function differs from string.format in that the order of the arguments
-- within the format string are specified within the format itself.
-- For example, the format "%3$d" gets replaced by the third argument (not
-- counting the format string itself) which gets formatted as a digit, as with
-- the "%d" format used in usual Lua patterns.
-- As another example, the call iformat("Hello, %2$s!", "Sunshi", "Kyaroh")
-- evaluates to "Hello, Kyaroh!".
-- The primary purpose is this function is to format localized strings, where
-- the order in which the arguments have to appear in the string may differ
-- between languages.
-- @tparam string format
-- The format string.
-- @param ...
-- Any number of values to be formatted into the format string.
-- @treturn string
-- The formatted string.
function M.iformat(format, ...)
  local args, order = {...}, {}
  format = format:gsub("%%(%d+)%$", function(i)
    table.insert(order, args[tonumber(i)])
    return "%"
  end)
  return string.format(format, unpack(order))
end

--- Compares two (semantic) version strings of the form 'x.y.z'.
-- @tparam string a
-- The first version string.
-- @tparam string b
-- The second version string.
-- @treturn number
-- A value that compares equal to 0 if the versions are equal;
-- less than 0 if the first version is an earlier version than the second;
-- greater than 0 if the first version is a later version than the second.
function M.compare_version(a, b)
  a = M.match(a, "%d+", tonumber)
  b = M.match(b, "%d+", tonumber)
  -- Index 1 is the major version; 2 the minor version; 3 the patch version.
  for i = 1, 3 do
    if a[i] > b[i] then return  1 end
    if a[i] < b[i] then return -1 end
  end
  return 0
end

--- Produces a subrange of a table.
-- @tparam table t
-- The table to get the subrange from.
-- @tparam number s
-- The inclusive index where the subrange starts.
-- @tparam number e
-- The inclusive index where the subrange ends.
-- @treturn table
-- The subrange.
function M.get_range(t, s, e)
  return {unpack(t, s, e)}
end

--- Produces a shallow copy of a table where a function has been applied over
--- every element.
-- @tparam table t
-- The table to map over.
-- @tparam function f
-- The function to apply to the elements in the table.
-- @treturn table
-- The table after the mapping.
function M.map(t, f)
  local r = {}
  for k, v in pairs(t) do
    r[k] = f(v)
  end
  return r
end

--- Checks if a given number is an integer.
-- @tparam number x
-- The number to check.
-- @treturn boolean
-- true if x is an integer, false otherwise.
function M.is_integer(x)
  return math.floor(x) == x
end

--- Evaluates a string as a Lua expression and displays the resulting value
--- in the chat.
-- This should only be used for debugging purposes.
-- @tparam string expr
-- A Lua expression as a string.
function M.dump(expr)
  SlashCmdList["DUMP"](expr)
end

CS.Core.Util = M
