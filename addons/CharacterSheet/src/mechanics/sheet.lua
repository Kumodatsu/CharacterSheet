--- Main functionality for character sheets.
-- Most operations involving attributes specifically can be found in the
-- @{Mechanics.Statblock} module.
-- @module Mechanics.Sheet
local _, CS = ...
M = {}

local insert = table.insert
local remove = table.remove

local Statblock = CS.Mechanics.Statblock

M.KNOCK_DOWN_HP     =  0
M.KNOCK_OUT_HP      = -5
M.PET_KNOCK_DOWN_HP = M.KNOCK_DOWN_HP
M.PET_KNOCK_OUT_HP  = M.KNOCK_OUT_HP

--- Initializes a new character sheet.
-- @treturn Sheet
-- The character sheet, with the fields 'statblock' (Statblock), 'hp' (number),
-- 'pet' (Pet or nil), and 'resources' (table of Resources).
-- A Pet is a table with the fields 'hp' (number), and 'attribute' (Attribute).
-- A Resource is a table with the fields 'name' (string), 'min_value' (number),
-- and 'max_value' (number).
function M.initialize_character_sheet()
  local stats = Statblock.initialize_default_statblock()
  return {
    statblock = stats,
    hp        = Statblock.get_max_hp(stats),
    pet       = nil,
    resources = {},
  }
end

-- @todo Implement rolls, likely in a different module

-- @todo Check if this is necessary
local function clamp_hp(sheet)
  local max_hp = Statblock.get_max_hp(sheet.statblock)
  if sheet.hp > max_hp then
    sheet.hp = max_hp
  end
  local max_pet_hp = Statblock.get_max_pet_hp(sheet.statblock)
  if sheet.pet and sheet.pet.hp > max_pet_hp then
    sheet.pet.hp = max_pet_hp
  end
end

--- Sets the HP on a sheet to the specified value.
-- The HP is set if and only if the value is within the allowed range.
-- @tparam Sheet sheet
-- @tparam number value
-- @treturn boolean
-- false if the specified value is outside the allowed range, true otherwise.
function M.set_hp(sheet, value)
  local max_hp = Statblock.get_max_hp(sheet.statblock)
  if value < M.KNOCK_OUT_HP or value > max_hp then
    return false
  end
  sheet.hp = value
  return true
end

--- Change the HP on a sheet by some amount.
-- The HP is set if and only if the resulting value is within the allowed range.
-- @tparam Sheet sheet
-- @tparam number amount
-- @treturn boolean
-- false if the resulting value is outside the allowed range, true otherwise.
function M.change_hp(sheet, amount)
  return M.set_hp(sheet, sheet.hp + amount)
end

--- Toggles the presence of a pet on a sheet.
-- Note that toggling the pet twice will reset it completely.
-- @tparam Sheet sheet
function M.toggle_pet(sheet)
  if sheet.pet then
    sheet.pet = nil
    return
  end
  sheet.pet = {
    hp        = Statblock.get_max_pet_hp(sheet.statblock),
    attribute = Statblock.Attribute.CHA,
  }
end

--- Sets the pet's HP on a sheet to a specified value.
-- The pet's HP is set if and only if the value is within the allowed range.
-- @tparam Sheet sheet
-- @tparam number value
-- @treturn boolean
-- false if there is no pet or if the value is outside of the allowed range,
-- true otherwise.
function M.set_pet_hp(sheet, value)
  if not sheet.pet then
    return false
  end
  local max_pet_hp = Statblock.get_max_pet_hp(sheet.statblock)
  if value < M.PET_KNOCK_OUT_HP or value > max_pet_hp then
    return false
  end
  sheet.pet.hp = value
  return true
end

--- Changes the pet's HP on a sheet by some amount.
-- The pet's HP is changed if and only if the resulting value is within the
-- allowed range.
-- @tparam Sheet sheet
-- @tparam number amount
-- @treturn boolean
-- false if there is no pet or if the value is outside of the allowed range,
-- true otherwise.
function M.change_pet_hp(sheet, amount)
  if not sheet.pet then
    return false
  end
  return M.set_pet_hp(sheet, sheet.pet.hp + amount)
end

--- Adds a custom resource to the character sheet.
-- If a resource with the same name already exists, it is overwritten.
-- @tparam Sheet sheet
-- @tparam string name
-- The name for the custom resource.
-- @tparam number value
-- @tparam number min_value
-- @tparam number max_value
function M.add_resource(sheet, name, value, min_value, max_value)
  if value < min_value then
    value = min_value
  elseif value > max_value then
    value = max_value
  end
  sheet.resources[name] = {
    name      = name,
    value     = value,
    min_value = min_value,
    max_value = max_value,
  }
end

--- Removes the resource with the given name from a character sheet.
-- This function errors if and only if no resource with that name exists in the
-- sheet.
-- @tparam Sheet sheet
-- @tparam string name
function M.remove_resource(sheet, name)
  if not sheet.resources[name] then
    error(string.format(
      "Attempt to remove non-existent resource '%s'.",
      name
    ))
  end
  sheet.resources[name] = nil
end

--- Sets the value of a resource in a sheet.
-- The value is only set if it is within the resource's allowed range.
-- This function errors if and only if the requested resource doesn't exist in
-- the sheet.
-- @tparam Sheet sheet
-- @tparam string name
-- @tparam number value
-- @treturn boolean
-- false if the specified value is outside the allowed range, true otherwise.
function M.set_resource_value(sheet, name, value)
  local resource = sheet.resources[name]
  if not resource then
    error(string.format(
      "Attempt to access non-existent resource '%s'.",
      name
    ))
  end
  if value < resource.min_value or value > resource.max_value then
    return false
  end
  resource.value = value
  return true
end

--- Changes the value of a resource in a sheet by some amount.
-- The resource's value is only changed if the resulting value is within the
-- resource's allowed range.
-- This function errors if and only if the requested resource doesn't exist in
-- the sheet.
-- @tparam Sheet sheet
-- @tparam string name
-- @tparam number amount
-- @treturn boolean
-- false if the resulting value is outside the allowed range, true otherwise.
function M.change_resource_value(sheet, name, amount)
  local resource = sheet.resources[name]
  if not resource then
    error(string.format(
      "Attempt to access non-existent resource '%s'.",
      name
    ))
  end
  return M.set_resource_value(sheet, name, resource.value + amount)
end

CS.Mechanics.Sheet = M
