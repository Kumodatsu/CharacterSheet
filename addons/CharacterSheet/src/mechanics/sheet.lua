--- Main functionality for character sheets.
-- Most operations involving attributes specifically can be found in the
-- @{Mechanics.Statblock} module.
-- @module Mechanics.Sheet
local _, CS = ...
M = {}

local insert = table.insert
local remove = table.remove

local Savedata = CS.Core.Savedata
local SB       = CS.Mechanics.Statblock

local enum_to_string = CS.Core.Util.enum_to_string
local register_event = CS.Core.Event.register_event
local string_to_enum = CS.Core.Util.string_to_enum
local translate      = CS.Core.Locale.translate

--- The HP value at which a character gets knocked down.
M.KNOCK_DOWN_HP     =  0
--- The HP value at which a character gets knocked out.
M.KNOCK_OUT_HP      = -5
--- The HP value at which a pet gets knocked down.
M.PET_KNOCK_DOWN_HP = M.KNOCK_DOWN_HP
--- The HP value at which a pet gets knocked out.
M.PET_KNOCK_OUT_HP  = M.KNOCK_OUT_HP

--- Fired when an attribute has changed in a character sheet.
-- @event CS.AttributeChanged
-- @tparam Sheet sheet
-- The character sheet that changed.
-- @tparam Attribute attribute
-- The attribute that changed in the character sheet.
-- @tparam number new_value
-- The new value of the attribute in the character sheet.
local on_attribute_changed = register_event "CS.AttributeChanged"

--- Fired when the power level has changed in a character sheet.
-- @event CS.PowerLevelChanged
-- @tparam Sheet sheet
-- The character sheet that changed.
-- @tparam PowerLevel new_value
-- The new value of the power level in the character sheet.
local on_power_level_changed = register_event "CS.PowerLevelChanged"

--- Fired when the max HP of a character sheet has changed.
-- @event CS.MaxHPChanged
-- @tparam Sheet sheet
-- The character sheet that changed.
-- @tparam number new_value
-- The new value of the max HP in the character sheet.
local on_max_hp_changed = register_event "CS.MaxHPChanged"

--- Fired when the max pet HP of a character sheet has changed.
-- @event CS.MaxPetHPChanged
-- @tparam Sheet sheet
-- The character sheet that changed.
-- @tparam number new_value
-- The new value of the max pet HP in the character sheet.
local on_max_pet_hp_changed = register_event "CS.MaxPetHPChanged"

--- Fired when the HP of a character sheet has changed.
-- @event CS.HPChanged
-- @tparam Sheet sheet
-- The character sheet that changed.
-- @tparam number new_value
-- The new value of the HP in the character sheet.
local on_hp_changed = register_event "CS.HPChanged"

--- Fired when the pet HP of a character sheet has changed.
-- @event CS.PetHPChanged
-- @tparam Sheet sheet
-- The character sheet that changed.
-- @tparam number new_value
-- The new value of the pet HP in the character sheet.
local on_pet_hp_changed = register_event "CS.PetHPChanged"

--- Fired when the pet has been toggled in a character sheet.
-- @event CS.PetToggled
-- @tparam Sheet sheet
-- The character sheet in which the pet was toggled.
-- @tparam ?Pet pet
-- nil if the pet was disabled, a table representing the pet otherwise.
local on_pet_toggled = register_event "CS.PetToggled"

--- Fired when the pet's attack attribute has changed in a character sheet.
-- @event CS.PetAttackAttributeChanged
-- @tparam Sheet sheet
-- The character sheet that changed.
-- @tparam Attribute attribute
-- The new attack attribute.
local on_pet_attack_attribute_changed =
  register_event "CS.PetAttackAttributeChanged"

--- Fired when a custom resource has been added to a character sheet.
-- @event CS.ResourceAdded
-- @tparam Sheet sheet
-- The character sheet to which the resource was added.
-- @tparam Resource resource
-- The resource that was added.
local on_resource_added = register_event "CS.ResourceAdded"

--- Fired when a custom resource has been removed from a character sheet.
-- @event CS.ResourceRemoved
-- @tparam Sheet sheet
-- The character sheet from which the resource was removed.
-- @tparam string resource_name
-- The name of the resource that was removed.
local on_resource_removed = register_event "CS.ResourceRemoved"

--- Fired when a custom resource has been updated in a character sheet.
-- @event CS.ResourceChanged
-- @tparam Sheet sheet
-- The character sheet which holds the updated resource.
-- @tparam string old_resource_name
-- The name the resource had originally.
-- This value is supplied separately since the resource's name may have changed.
-- @tparam Resource resource
-- The updated value of the resource.
local on_resource_changed = register_event "CS.ResourceChanged"

--- Initializes a new character sheet.
-- @treturn Sheet
-- The character sheet, with the fields 'statblock' (Statblock), 'hp' (number),
-- 'pet' (Pet or nil), and 'resources' (table of Resources).
-- A Pet is a table with the fields 'hp' (number), and 'attribute' (Attribute).
-- A Resource is a table with the fields 'name' (string), 'min_value' (number),
-- 'max_value' (number) and 'value' (number).
function M.initialize_character_sheet()
  local stats = SB.initialize_default_statblock()
  return {
    statblock = stats,
    hp        = SB.get_max_hp(stats),
    pet       = nil,
    resources = {},
  }
end

--- Gets the character sheet from the currently active profile.
-- @treturn Sheet
function M.get_active_sheet()
  local data = Savedata.get_profile_data()
  data.sheet = data.sheet or M.initialize_character_sheet()
  return data.sheet
end

--- Clamps the HP values in a character sheet in case the maximum HP has
--- changed.
-- @tparam Sheet sheet
-- @treturn boolean
-- true if the HP value has changed, false otherwise.
-- @treturn number
-- The current maximum HP value of the sheet.
-- @treturn boolean
-- true if the pet's HP value has changed, false otherwise.
-- @treturn number
-- The current maximum pet HP value of the sheet.
local function clamp_hp(sheet)
  local max_hp     = SB.get_max_hp(sheet.statblock)
  local hp_changed = sheet.hp > max_hp
  if hp_changed then
    sheet.hp = max_hp
  end
  local max_pet_hp     = SB.get_max_pet_hp(sheet.statblock)
  local pet_hp_changed = sheet.pet and sheet.pet.hp > max_pet_hp
  if pet_hp_changed then
    sheet.pet.hp = max_pet_hp
  end
  return hp_changed, max_hp, pet_hp_changed, max_pet_hp
end

--- Sets an attribute in a character sheet's statblock to a value.
-- This function only actually performs the operation if the statblock would
-- still be valid after the change.
-- @tparam Sheet sheet
-- @tparam Attribute attribute
-- @tparam number value
-- @treturn boolean
-- true if the change was valid (and thus the statblock has been changed), false
-- otherwise.
-- @treturn ?string
-- If the operation was invalid, a localized string describing what went wrong.
function M.set_attribute(sheet, attribute, value)
  -- Check if value is within the allowed range.
  if value < SB.MIN_ATTRIBUTE_VALUE or value > SB.MAX_ATTRIBUTE_VALUE then
    return false,
    translate("MSG_RANGE", SB.MIN_ATTRIBUTE_VALUE, SB.MAX_ATTRIBUTE_VALUE)
  end

  local statblock     = sheet.statblock
  local current_value = statblock.attributes[attribute]
  
  -- Check if the character has enough skill points.
  local difference    = value - current_value
  local remaining_sp  = SB.get_remaining_available_sp(statblock) - difference
  if remaining_sp < 0 then
    return false, translate("MSG_TOO_MANY_SP", -remaining_sp)
  end

  statblock.attributes[attribute] = value

  -- Clamp the character's HP if necessary.
  local con_changed = attribute == SB.Attribute.CON
  -- These 4 variables should only be read if con_changed == true
  local hp_changed, max_hp, pet_hp_changed, max_pet_hp
  if con_changed then
    hp_changed, max_hp, pet_hp_changed, max_pet_hp = clamp_hp(sheet)
  end

  -- Fire events depending on changes to the sheet.
  -- This is done at the very end to make sure that the sheet table passed to
  -- the events is always in a valid state.
  on_attribute_changed(sheet, attribute, value)
  if con_changed then
    on_max_hp_changed(sheet, max_hp)
    on_max_pet_hp_changed(sheet, max_pet_hp)
    if hp_changed     then on_hp_changed(sheet, sheet.hp)         end
    if pet_hp_changed then on_pet_hp_changed(sheet, sheet.pet.hp) end
  end
  
  return true
end

--- Sets the power level in a character sheet's statblock.
-- If the change causes the total number of allowed SP to be fewer than the
-- number actually spent, points will be taken out of the attributes until the
-- statblock becomes valid again.
-- @tparam Sheet sheet
-- @tparam PowerLevel power_level
-- @treturn boolean
-- true if the power level was set without any changes to the attributes,
-- false if the power level was set and attribute values have been changed.
function M.set_power_level(sheet, power_level)
  local statblock          = sheet.statblock
  local changed_attributes = {}

  -- Check if any attributes should be reduced to make sure the skill point
  -- distribution remains valid after the change of power level.
  if power_level < statblock.power_level then
    local remaining_sp  = SB.get_remaining_available_sp(statblock)
    local max_sp_change = SB.get_potential_sp(power_level) -
      SB.get_potential_sp(statblock.power_level)
    remaining_sp = remaining_sp + max_sp_change
    for _, attribute in ipairs {
      SB.Attribute.STR,
      SB.Attribute.DEX,
      SB.Attribute.CON,
      SB.Attribute.INT,
      SB.Attribute.WIS,
      SB.Attribute.CHA,
    } do
      while statblock.attributes[attribute] > SB.MIN_ATTRIBUTE_VALUE and
          remaining_sp < 0 do
        statblock.attributes[attribute] = statblock.attributes[attribute] - 1
        remaining_sp                    = remaining_sp + 1
        changed_attributes[attribute]   = true
      end
    end
  end

  statblock.power_level = power_level
  local hp_changed, max_hp, pet_hp_changed, max_pet_hp = clamp_hp(sheet)

  -- Fire events depending on the changes to the sheet.
  -- This is done at the very end to make sure that the sheet table passed to
  -- the events is always in a valid state.
  on_power_level_changed(sheet, power_level)
  for attribute, _ in pairs(changed_attributes) do
    on_attribute_changed(sheet, attribute, statblock.attributes[attribute])
  end
  on_max_hp_changed(sheet, max_hp)
  on_max_pet_hp_changed(sheet, max_pet_hp)
  if hp_changed     then on_hp_changed(sheet, sheet.hp)         end
  if pet_hp_changed then on_pet_hp_changed(sheet, sheet.pet.hp) end

  return next(changed_attributes) == nil
end

--- Sets the HP on a sheet to the specified value.
-- The HP is set if and only if the value is within the allowed range.
-- @tparam Sheet sheet
-- @tparam number value
-- @treturn boolean
-- false if the specified value is outside the allowed range, true otherwise.
-- @treturn ?string
-- If the value is invalid, a message describing the error.
function M.set_hp(sheet, value)
  local max_hp = SB.get_max_hp(sheet.statblock)
  if value < M.KNOCK_OUT_HP or value > max_hp then
    return false, translate "MSG_SET_HP_ALLOWED_VALUES"
  end
  sheet.hp = value
  on_hp_changed(sheet, value)
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
-- @treturn boolean
-- true if the pet is now active, false if the pet is now inactive.
function M.toggle_pet(sheet)
  if sheet.pet then
    sheet.pet = nil
  else
    sheet.pet = {
      hp        = SB.get_max_pet_hp(sheet.statblock),
      attribute = SB.Attribute.CHA,
    }
  end
  on_pet_toggled(sheet, sheet.pet)
  return sheet.pet ~= nil
end

--- Sets the pet's HP on a sheet to a specified value.
-- The pet's HP is set if and only if the value is within the allowed range.
-- @tparam Sheet sheet
-- @tparam number value
-- @treturn boolean
-- false if there is no pet or if the value is outside of the allowed range,
-- true otherwise.
-- @treturn ?string
-- In case the operation was invalid, a message describing the erorr.
function M.set_pet_hp(sheet, value)
  if not sheet.pet then
    return false, translate "MSG_NO_PETS"
  end
  local max_pet_hp = SB.get_max_pet_hp(sheet.statblock)
  if value < M.PET_KNOCK_OUT_HP or value > max_pet_hp then
    return false, translate "MSG_SET_HP_ALLOWED_VALUES"
  end
  sheet.pet.hp = value
  on_pet_hp_changed(sheet, value)
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

--- Changes the attribute used for pet attacks.
-- @tparam Sheet sheet
-- @tparam Attribute attribute
-- @treturn boolean
-- false if there is no pet, true otherwise.
function M.set_pet_attack_attribute(sheet, attribute)
  if not sheet.pet then
    return false
  end
  sheet.pet.attribute = attribute
  on_pet_attack_attribute_changed(sheet, attribute)
  return true
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
  on_resource_added(sheet, sheet.resources[name])
end

--- Removes the resource with the given name from a character sheet.
-- @tparam Sheet sheet
-- @tparam string name
-- @treturn boolean
-- true if the resource was removed, false if there is no resource with the
-- given name.
-- @treturn ?string
-- In case of an invalid operation, a message describing the error.
function M.remove_resource(sheet, name)
  if not sheet.resources[name] then
    return false, translate("MSG_RESOURCE_DOESNT_EXIST", name)
  end
  sheet.resources[name] = nil
  on_resource_removed(sheet, name)
  return true
end

--- Sets the value of a resource in a sheet.
-- The value is only set if it is within the resource's allowed range.
-- @tparam Sheet sheet
-- @tparam string name
-- @tparam number value
-- @treturn boolean
-- false if the specified value is outside the allowed range, true otherwise.
-- @treturn ?string
-- In case of an invalid operation, a message describing the error.
function M.set_resource_value(sheet, name, value)
  local resource = sheet.resources[name]
  if not resource then
    return false, translate("MSG_RESOURCE_DOESNT_EXIST", name)
  end
  if value < resource.min_value or value > resource.max_value then
    return false, translate("MSG_RESOURCE_ALLOWED_VALUES", name,
      resource.min_value, resource.max_value)
  end
  resource.value = value
  on_resource_changed(sheet, name, resource)
  return true
end

--- Changes the value of a resource in a sheet by some amount.
-- The resource's value is only changed if the resulting value is within the
-- resource's allowed range.
-- @tparam Sheet sheet
-- @tparam string name
-- @tparam number amount
-- @treturn boolean
-- false if the resulting value is outside the allowed range, true otherwise.
-- @treturn ?string
-- In case of an invalid operation, a message describing the error.
function M.change_resource_value(sheet, name, amount)
  local resource = sheet.resources[name]
  if not resource then
    return false, translate("MSG_RESOURCE_DOESNT_EXIST", name)
  end
  return M.set_resource_value(sheet, name, resource.value + amount)
end

CS.Mechanics.Sheet = M
