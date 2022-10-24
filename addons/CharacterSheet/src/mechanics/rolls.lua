--- Functions to initiate different types of rolls.
-- @module Mechanics.Rolls
local _, CS = ...
local M = {}

local ceil = math.ceil

local SB = CS.Mechanics.Statblock

local attribute_to_string = SB.attribute_to_string
local display             = CS.Core.Util.display
local enum_to_string      = CS.Core.Util.enum_to_string
local get_active_sheet    = CS.Mechanics.Sheet.get_active_sheet
local iformat             = CS.Core.Util.iformat
local register_cmd        = CS.Core.Command.register_cmd
local roll                = CS.Mechanics.Rolling.roll
local string_to_attribute = SB.string_to_attribute
local string_to_enum      = CS.Core.Util.string_to_enum
local subscribe_event     = CS.Core.Event.subscribe_event
local translate           = CS.Core.Locale.translate

M.SAFE_HEAL_DIE   = 14
M.COMBAT_HEAL_DIE = 10

M.CombatState = {
  SAFE   = 1,
  COMBAT = 2,
}

M.string_to_combat_state = string_to_enum(M.CombatState)
M.combat_state_to_string = enum_to_string(M.CombatState)

M.RollType = {
  Attribute = "CS.Attribute",
  Heal      = "CS.Heal",
  PetAttack = "CS.PetAttack",
}

function M.roll_attribute(attribute, modifier)
  modifier = modifier or 0
  roll(1, 20, {
    type      = M.RollType.Attribute,
    attribute = attribute,
    modifier  = modifier,
  })  
end

function M.roll_heal(combat_state, modifier)
  combat_state = combat_state or CombatState.SAFE
  modifier     = modifier     or 0
  local die
  if combat_state == M.CombatState.SAFE then
    die = M.SAFE_HEAL_DIE
  else 
    die = M.COMBAT_HEAL_DIE
  end
  roll(1, die, {
    type     = M.RollType.Heal,
    modifier = modifier,
  })
end

function M.roll_pet_attack(modifier)
  modifier = modifier or 0
  roll(1, 20, {
    type     = M.RollType.PetAttack,
    modifier = modifier,
  })
end

local function display_roll_output(msg)
  display(msg)
end

local function format_natural_extreme_roll(raw_roll, lower_bound, upper_bound)
  if raw_roll == upper_bound then
    return "(" .. translate("NATURAL", upper_bound) .. ")"
  elseif raw_roll == lower_bound then
    return "(" .. translate("NATURAL", lower_bound) .. ")"
  end
  return nil
end

local function handle_attribute(sheet, data, raw_roll, lower_bound, upper_bound)
  local roll = raw_roll + sheet.statblock.attributes[data.attribute] +
    data.modifier
  display_roll_output(iformat(
    "%1$d %2$s %3$s",
    roll,
    attribute_to_string(data.attribute),
    format_natural_extreme_roll(raw_roll, lower_bound, upper_bound) or ""
  ))
end

local function handle_heal(sheet, data, raw_roll, lower_bound, upper_bound)
  local roll = raw_roll + SB.get_heal_modifier(sheet.statblock) +
    data.modifier
  display_roll_output(iformat(
    "%1$d %2$s",
    roll,
    format_natural_extreme_roll(raw_roll, lower_bound, upper_bound) or ""
  ))
end

local function handle_pet_attack(sheet, data, raw_roll, lower_bound,
    upper_bound)
  local pet = sheet.pet
  if not pet then return end

  local roll =
    ceil((raw_roll + sheet.statblock.attributes[pet.attribute]) / 2) +
    data.modifier
  display_roll_output(iformat(
    "%1$d %2$s",
    roll,
    format_natural_extreme_roll(raw_roll, lower_bound, upper_bound) or ""
  ))
end

subscribe_event("CS.Rolled", function(data, raw_roll, lower_bound, upper_bound)
  if type(data) ~= "table" then
    return
  end
  local sheet = get_active_sheet()
  if not sheet then
    return
  end 

  if data.type == M.RollType.Attribute then
    handle_attribute(sheet, data, raw_roll, lower_bound, upper_bound)
  elseif data.type == M.RollType.Heal then
    handle_heal(sheet, data, raw_roll, lower_bound, upper_bound)
  elseif data.type == M.RollType.PetAttack then
    handle_pet_attack(sheet, data, raw_roll, lower_bound, upper_bound)
  end
end)

CS.Mechanics.Rolls = M
