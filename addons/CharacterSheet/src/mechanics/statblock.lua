--- Functionality for a stat block, which is the static part of a character
--- sheet, i.e. the values that don't typically change during an event.
-- @module Mechanics.Statblock
local _, CS = ...
local M = {}

local floor = math.floor
local max   = math.max

local enum_to_string = CS.Core.Util.enum_to_string
local string_to_enum = CS.Core.Util.string_to_enum

--- The minimum value an attribute is allowed to have.
M.MIN_ATTRIBUTE_VALUE = 5
--- The maximum value an attribute is allowed to have.
M.MAX_ATTRIBUTE_VALUE = 24

--- Enumeration of power levels.
-- Power levels can be compared with the usual comparison operators
-- (<, >, <=, >=, ==, ~=).
-- A power level being "less than" another means it's a lower power level and
-- vice versa for "greater than".
M.PowerLevel = {
  NOVICE     = 1, -- Lowest power level (76 SP, +2 HP).
  APPRENTICE = 2, -- Default power level (78 SP, +4 HP).
  ADEPT      = 3, -- Average power level (80 SP, +6 HP).
  EXPERT     = 4, -- Second highest power level (82 SP, +8 HP).
  MASTER     = 5, -- Highest power level (84 SP, +10 HP).
}

--- Enumeration of attributes.
M.Attribute = {
  STR = 1, -- Strength.
  DEX = 2, -- Dexterity.
  CON = 3, -- Constitution. Influences player's HP.
  INT = 4, -- Intelligence.
  WIS = 5, -- Wisdom.
  CHA = 6, -- Charisma. Influences player's heal modifier and pet damage.
}

--- Converts the name of a power level to the actual power level.
-- This function returns nil if the conversion isn't possible.
-- @function string_to_power_level
-- @tparam string s
-- @treturn ?PowerLevel
M.string_to_power_level = string_to_enum(M.PowerLevel)

--- Converts a power level to its name as a string.
-- This function returns nil if the conversion isn't possible.
-- @function power_level_to_string
-- @tparam PowerLevel power_level
-- @treturn ?string
M.power_level_to_string = enum_to_string(M.PowerLevel)

--- Converts the abbreviation of an attribute to the actual attribute.
-- This function returns nil if the conversion isn't possible.
-- @function string_to_attribute
-- @tparam string s
-- @treturn ?Attribute
M.string_to_attribute = string_to_enum(M.Attribute)

--- Converts an attribute to its abbreviation as a string.
-- This function returns nil if the conversion isn't possible.
-- @function attribute_to_string
-- @tparam Attribute attribute
-- @treturn ?string
M.attribute_to_string = enum_to_string(M.Attribute)

--- Initializes a new statblock.
-- @treturn Statblock
-- The statblock, having the keys 'attributes' (table) and 'power_level'
-- (PowerLevel).
-- The attributes table's keys are from the
-- @{Mechanics.Statblock.Attribute|Attribute} enumeration and its values
-- are numbers.
function M.initialize_default_statblock()
  return {
    attributes = {
      [M.Attribute.STR] = 13,
      [M.Attribute.DEX] = 13,
      [M.Attribute.CON] = 13,
      [M.Attribute.INT] = 13,
      [M.Attribute.WIS] = 13,
      [M.Attribute.CHA] = 13,
    },
    power_level = M.PowerLevel.APPRENTICE,
  }
end

--- Gets the SP (skill points) bonus available to a character with a specific
-- power level.
-- This is the bonus players receive from their power level, not including the
-- base points everyone has.
-- Use @{Mechanics.Statblock.get_potential_sp|get_potential_sp} for the total
-- SP.
-- @tparam PowerLevel power_level
-- @treturn number
function M.get_sp_bonus(power_level)
  return 14 + 2 * power_level
end

--- Gets the HP bonus available to a character with a specific power level.
-- This does not include the HP gained from the constitution attribute.
-- Use @{Mechanics.Statblock.get_max_hp|get_max_hp} for the total HP.
-- @tparam PowerLevel power_level
-- @treturn number
function M.get_hp_bonus(power_level)
  return 2 * power_level
end

--- Gets the max HP for a character with the given statblock.
-- @tparam Statblock statblock
-- @treturn number
function M.get_max_hp(statblock)
  local con = statblock.attributes[M.Attribute.CON]
  return con + M.get_hp_bonus(statblock.power_level)
end

--- Gets the max pet HP for a character with the given statblock.
-- @tparam Statblock statblock
-- @treturn number
function M.get_max_pet_hp(statblock)
  return M.get_max_hp(statblock)
end

--- Gets the maximum SP a character with the given power level may spend on
--- their attributes.
-- @tparam PowerLevel power_level
-- @treturn number
function M.get_potential_sp(power_level)
  return 60 + M.get_sp_bonus(power_level)
end

--- Gets the total number of SP spent on attributes in the given statblock.
-- @tparam Statblock statblock
-- @treturn number
function M.get_total_spent_sp(statblock)
  local total = 0
  for _, attribute in pairs(statblock.attributes) do
    total = total + attribute
  end
  return total
end

--- Gets the number of SP that may still be spent on attributes in the given
--- statblock.
-- @tparam Statblock statblock
-- @treturn number
function M.get_remaining_available_sp(statblock)
  return M.get_potential_sp(statblock.power_level) -
    M.get_total_spent_sp(statblock)
end

--- Gets the heal modifier from the given statblock.
-- @tparam Statblock statblock
-- @treturn number
function M.get_heal_modifier(statblock)
  return floor(max(0, statblock.attributes[M.Attribute.CHA] - 10) / 2)
end

CS.Mechanics.Statblock = M
