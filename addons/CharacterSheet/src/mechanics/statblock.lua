--- Functionality for a stat block, which is the static part of a character
--- sheet, i.e. the values that don't typically change during an event.
-- @module Mechanics.Statblock
local _, CS = ...
local M = {}

local floor = math.floor
local max   = math.max

local enum_to_string = CS.Core.Util.enum_to_string
local string_to_enum = CS.Core.Util.string_to_enum
local translate      = CS.Core.Locale.translate

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
M.string_to_attribute   = string_to_enum(M.Attribute)

--- Converts an attribute to its abbreviation as a string.
-- This function returns nil if the conversion isn't possible.
-- @function attribute_to_string
-- @tparam Attribute attribute
-- @treturn ?string
M.attribute_to_string   = enum_to_string(M.Attribute)

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

--- Sets an attribute in a statblock to a value.
-- This function only actually performs the operation if the statblock would
-- still be valid after the change.
-- @tparam Statblock statblock
-- @tparam Attribute attribute
-- @tparam number value
-- @treturn boolean
-- true if the change was valid (and thus the statblock has been changed), false
-- otherwise.
-- @treturn ?string
-- If the operation was invalid, a localized string describing what went wrong.
function M.set_attribute(statblock, attribute, value)
  if value < M.MIN_ATTRIBUTE_VALUE or value > M.MAX_ATTRIBUTE_VALUE then
    return false,
      translate("MSG_RANGE", M.MIN_ATTRIBUTE_VALUE, M.MAX_ATTRIBUTE_VALUE)
  end
  local current_value = statblock.attributes[attribute]
  local difference    = value - current_value
  local remaining_sp  = M.get_remaining_available_sp(statblock) - difference
  if remaining_sp < 0 then
    return false, translate("MSG_TOO_MANY_SP", -remaining_sp)
  end
  statblock.attributes[attribute] = value
  return true
end

--- Sets the power level in a statblock.
-- If the change causes the total number of allowed SP to be fewer than the
-- number actually spent, points will be taken out of the attributes until the
-- statblock becomes valid again.
-- @tparam Statblock statblock
-- @tparam PowerLevel power_level
-- @treturn boolean
-- true if the power level was set without any changes to the attributes,
-- false if the power level was set and attribute values have been changed.
function M.set_power_level(statblock, power_level)
  local are_attributes_changed = false
  if power_level < statblock.power_level then
    local remaining_sp  = M.get_remaining_available_sp(statblock)
    local max_sp_change = M.get_potential_sp(power_level) -
      M.get_potential_sp(statblock.power_level)
    remaining_sp = remaining_sp + max_sp_change
    for _, attribute in ipairs {
      M.Attribute.STR,
      M.Attribute.DEX,
      M.Attribute.CON,
      M.Attribute.INT,
      M.Attribute.WIS,
      M.Attribute.CHA,
    } do
      while statblock.attributes[attribute] > M.MIN_ATTRIBUTE_VALUE and
          remaining_sp < 0 do
        statblock.attributes[attribute] = statblock.attributes[attribute] - 1
        remaining_sp                    = remaining_sp + 1
        are_attributes_changed          = true
      end
    end
  end
  statblock.power_level = power_level
  return are_attributes_changed
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
