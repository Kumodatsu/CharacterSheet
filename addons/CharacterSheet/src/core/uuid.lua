--- Functionality for generating Universally Unique Identifiers.
-- @module Core.UUID

--[[
Copyright 2012 Rackspace; 2022 Kumodatsu (modifications)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Modifications compared to the original, made in 2022 by Kumodatsu:

Code style and identifier names have been altered to comply with the style of
Kumodatsu's "Character Sheet" World of Warcraft addon. Some code has also been
modified to improve performance and/or readability. The code has also been
altered to integrate with the addon's code base. Comments have been modified
accordingly. Functionally, the `hwaddr` parameter has been removed and bytes are
generated purely by math.random calls. This is not ideal but good enough for the
addon's purposes. The UUID generation now also immediately converts the UUID to
a string.
--]]

local addon_name, CS = ...
local M = {}

local random = math.random
local floor  = math.floor
local insert = table.insert
local sub    = string.sub
local format = string.format

--- Returns the bitwise operation specified by a truth matrix on two numbers.
local function bitwise(matrix)
  return function(x, y)
    local z   = 0
    local pow = 1
    while x > 0 or y > 0 do
      z   = z + (matrix[x % 2 + 1][y % 2 + 1] * pow)
      pow = pow * 2
      x   = floor(x / 2)
      y   = floor(y / 2)
    end
    return z
  end
end

local bitwise_and = bitwise {{0, 0}, {0, 1}}
local bitwise_or  = bitwise {{0, 1}, {1, 1}}

--- Converts an integer to its hexadecimal representation as a string.
local function int_to_hex(x)
  local s    = ""
  local base = 16
  local d    = nil
  while x > 0 do
    d = x % base + 1
    x = floor(x / base)
    s = sub("0123456789abcdef", d, d) .. s
  end
  while #s < 2 do
    s = "0" .. s
  end
  return s
end

--- Generates a universally unique identifier.
-- This function should return a unique random string every time it's called,
-- even across different clients.
-- The probability of two invocations returning the same string is negligible.
-- @treturn string
-- The generated UUID.
function M.generate_uuid()
  -- Bytes are treated as 8-bit unsigned bytes.
  local bytes = {}
  for i = 1, 16 do
    insert(bytes, random(0, 255))
  end
  -- Set the version.
  bytes[7] = bitwise_or(bitwise_and(bytes[7], 0x0f), 0x40)
  -- Set the variant.
  bytes[9] = bitwise_or(bitwise_and(bytes[7], 0x3f), 0x80)
  -- Convert the generated bytes to a string.
  for i = 1, #bytes do
    bytes[i] = int_to_hex(bytes[i])
  end
  return format(
    "%s%s%s%s-%s%s-%s%s-%s%s-%s%s%s%s%s%s",
    bytes[ 1], bytes[ 2], bytes[ 3], bytes[ 4],
    bytes[ 5], bytes[ 6], bytes[ 7], bytes[ 8],
    bytes[ 9], bytes[10], bytes[11], bytes[12],
    bytes[13], bytes[14], bytes[15], bytes[16]
  )
end

CS.Core.UUID = M
