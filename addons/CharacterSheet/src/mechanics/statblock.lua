--- Functionality for a stat block, which is the static part of a character
--- sheet, i.e. the values that don't typically change during an event.
-- @module Mechanics.Statblock
local _, CS = ...
local M = {}

local floor = math.floor
local max   = math.max

--- Enumeration of power levels.
M.PowerLevel = {
  NOVICE     = 1, -- Lowest power level (76 SP, +2 HP).
  APPRENTICE = 2, -- Default power level (78 SP, +4 HP).
  ADEPT      = 3, -- Average power level (80 SP, +6 HP).
  EXPERT     = 4, -- Second highest power level (82 SP, +8 HP).
  MASTER     = 5, -- Highest power level (84 SP, +10 HP).
}

--- Initializes a new statblock.
-- @treturn Statblock
-- The statblock, having the keys 'attributes' (table) and 'power_level'
-- (PowerLevel).
-- The attributes table has the keys 'str', 'dex', 'con', 'int', 'wis' and
-- 'cha', each of which is a number.
function M.initialize_default_statblock()
  return {
    attributes = {
      str = 13,
      dex = 13,
      con = 13,
      int = 13,
      wis = 13,
      cha = 13,
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
  return statblock.attributes.con + M.get_hp_bonus(statblock.power_level)
end

--- Gets the max pet HP for a character with the given statblock.
-- @tparam Statblock statblock
-- @treturn number
function M.get_pet_max_hp(statblock)
  return M.get_max_hp(statblock)
end

--- Gets the maximum SP a character with the given statblock may spent on their
--- attributes.
-- @tparam Statblock statblock
-- @treturn number
function M.get_potential_sp(statblock)
  return 60 + M.get_sp_bonus(statblock.power_level)
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
  return M.get_potential_sp(statblock) - M.get_total_spent_sp(statblock)
end

--- Gets the heal modifier from the given statblock.
-- @tparam Statblock statblock
-- @treturn number
function M.get_heal_modifier(statblock)
  return floor(max(0, statblock.attributes.cha - 10) / 2)
end

CS.Mechanics.Statblock = M
