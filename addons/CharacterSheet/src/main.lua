local _, CS = ...

local format = string.format
local insert = table.insert

local Savedata  = CS.Core.Savedata
local Sheet     = CS.Mechanics.Sheet
local Statblock = CS.Mechanics.Statblock
local Rolling   = CS.Mechanics.Rolling
local Rolls     = CS.Mechanics.Rolls

local Attribute = Statblock.Attribute

local attribute_to_string   = Statblock.attribute_to_string
local string_to_attribute   = Statblock.string_to_attribute
local power_level_to_string = Statblock.power_level_to_string
local string_to_power_level = Statblock.string_to_power_level

local display          = CS.Core.Util.display
local get_active_sheet = CS.Mechanics.Sheet.get_active_sheet
local register_cmd     = CS.Core.Command.register_cmd
local subscribe_event  = CS.Core.Event.subscribe_event
local translate        = CS.Core.Locale.translate

register_cmd("create-profile", "CMD_DESC_CREATE_PROFILE", function(name)
  if not name or name == "" then
    display(translate "MSG_INVALID_PROFILE_NAME")
    return
  end
  Savedata.create_profile(name)
end)

register_cmd("use-profile", "CMD_DESC_USE_PROFILE", function(name, index)
  if not name or name == "" then
    display(translate "MSG_INVALID_PROFILE_NAME")
    return
  end
  index = tonumber(index)

  local matching_profiles = {}
  local desired_id        = nil
  for id, profile in Savedata.iterate_profiles() do
    if profile.name == name then
      insert(matching_profiles, profile)
    end
  end
  if #matching_profiles == 0 then
    display(translate("MSG_NO_MATCHING_PROFILES", name))
    return
  elseif #matching_profiles > 1 then
    if not index then
      local match_list = ""
      for i, profile in ipairs(matching_profiles) do
        if i ~= 1 then
          match_list = match_list .. "\n"
        end
        match_list = match_list .. format("%d: %s", i, profile.name)
      end
      display(translate("MSG_MULTIPLE_MATCHING_PROFILES", name, match_list))
      return
    end
    if not matching_profiles[index] then
      display(translate("MSG_INVALID_PROFILE_MATCH_INDEX", index))
      return
    end
    desired_id = matching_profiles[index].id
  else
    desired_id = matching_profiles[1].id
  end
  Savedata.set_active_profile(desired_id)
end)

register_cmd("set", "CMD_DESC_SET", function(attribute_name, value)
  if not attribute_name then
    display(translate "MSG_REQUIRE_VALID_ATTRIBUTE")
    return
  end
  local attribute = string_to_attribute(attribute_name)
  if not attribute then
    display(translate("MSG_INVALID_STAT", attribute_name))
    return
  end
  value = tonumber(value)
  if not value then
    display(translate "MSG_REQUIRE_VALUE")
    return
  end

  local sheet = get_active_sheet()
  if not sheet then
    display(translate "MSG_NO_ACTIVE_PROFILE")
    return
  end
  local success, msg = Sheet.set_attribute(sheet, attribute, value)
  display(
    success and translate("MSG_STAT_SET", attribute_name:upper(), value) or msg
  )
end)

register_cmd("level", "CMD_DESC_LEVEL", function(power_level_name)
  level = string_to_power_level(power_level_name)
  if not level then
    display(translate("MSG_INVALID_POWER_LEVEL", power_level_name))
    return
  end
  local sheet = get_active_sheet()
  if not sheet then
    display(translate "MSG_NO_ACTIVE_PROFILE")
    return
  end
  local success = Sheet.set_power_level(sheet, level)
  display(translate("MSG_POWER_LEVEL_SET", power_level_to_string(level)))
end)

register_cmd("hp", "CMD_DESC_HP", function(value)
  local sheet = get_active_sheet()
  if not sheet then
    display(translate "MSG_NO_ACTIVE_PROFILE")
    return
  end
  if value == "max" then
    value = Statblock.get_max_hp(sheet.statblock)
  else
    value = tonumber(value)
  end
  if not value then
    display(translate "MSG_SET_HP_ALLOWED_ARGUMENTS")
    return
  end

  local success, msg = Sheet.set_hp(sheet, value)
  display(success and translate("MSG_HP_SET", value) or msg)
end)

register_cmd("stats", "CMD_DESC_STATS", function()
  local sheet = get_active_sheet()
  local sheet = get_active_sheet()
  if not sheet then
    display(translate "MSG_NO_ACTIVE_PROFILE")
    return
  end
  local stats = sheet.statblock.attributes
  for _, attribute in ipairs {
    Attribute.STR,
    Attribute.DEX,
    Attribute.CON,
    Attribute.INT,
    Attribute.WIS,
    Attribute.CHA,
  } do
    display(
      "%1$s: %2$d",
      translate(attribute_to_string(attribute)),
      stats[attribute]
    )
  end
  display(
    "%1$s: %2$d/%3$d",
    translate "HP",
    sheet.hp,
    Statblock.get_max_hp(sheet.statblock)
  )
  if sheet.pet then
    display(
      "%1$s: %2$d/%3$d",
      translate "PET",
      sheet.pet.hp,
      Statblock.get_max_pet_hp(sheet.statblock)
    )
  end
  for _, resource in pairs(sheet.resources) do
     display(
      "%1$s: %2$d/%3$d",
      resource.name,
      resource.value,
      resource.max_value
    )
  end
end)

register_cmd("roll", "CMD_DESC_ROLL", function(attribute_name, modifier)
  if not attribute_name then
    display(translate "MSG_REQUIRE_VALID_ATTRIBUTE")
    return
  end
  local attribute = string_to_attribute(attribute_name)
  if not attribute then
    display(translate("MSG_INVALID_STAT", attribute_name))
    return
  end

  Rolls.roll_attribute(attribute, tonumber(modifier))
end)

register_cmd("heal", "CMD_DESC_HEAL", function(combat_state, modifier)
  combat_state = combat_state or "safe"
  combat_state = Rolls.string_to_combat_state(combat_state)
  if not combat_state then
    display(translate("MSG_ALLOWED_PARAMETERS", "'safe', 'combat'"))
    return
  end
  
  Rolls.roll_heal(combat_state, tonumber(modifier))
end)

register_cmd("pet", "CMD_DESC_PET", function()
  local sheet = get_active_sheet()
  if not sheet then
    display(translate "MSG_NO_ACTIVE_PROFILE")
    return
  end

  local pet_active = Sheet.toggle_pet(sheet)
  display(translate(
    pet_active and "MSG_ACTIVE_PET_SET" or "MSG_ACTIVE_PET_UNSET"
  ))
end)

register_cmd("pet-hp", "CMD_DESC_PET_HP", function(value)
  local sheet = get_active_sheet()
  if not sheet then
    display(translate "MSG_NO_ACTIVE_PROFILE")
    return
  elseif not sheet.pet then
    display(translate "MSG_NO_PETS")
    return
  end
  if value == "max" then
    value = Statblock.get_max_pet_hp(sheet.statblock)
  else
    value = tonumber(value)
  end
  if not value then
    display(translate "MSG_SET_HP_ALLOWED_ARGUMENTS")
    return
  end

  local success, msg = Sheet.set_pet_hp(sheet, value)
  display(success and translate("MSG_PET_HP_SET", value) or msg)
end)


register_cmd("pet-attack", "CMD_DESC_PET_ATTACK", function(modifier)
  local sheet = get_active_sheet()
  if not sheet then
    display(translate "MSG_NO_ACTIVE_PROFILE")
    return
  elseif not sheet.pet then
    display(translate "MSG_NO_PETS")
    return
  end

  Rolls.roll_pet_attack(tonumber(modifier))
end)

register_cmd("set-pet-attribute", "CMD_DESC_SET_PET_ATTRIBUTE",
    function(attribute_name)
  local sheet = get_active_sheet()
  if not sheet then
    display(translate "MSG_NO_ACTIVE_PROFILE")
    return
  elseif not sheet.pet then
    display(translate "MSG_NO_PETS")
    return
  end
  if not attribute_name then
    display(translate "MSG_REQUIRE_VALID_ATTRIBUTE")
    return
  end
  local attribute = string_to_attribute(attribute_name)
  if not attribute then
    display(translate("MSG_INVALID_STAT", attribute_name))
    return
  end

  Sheet.set_pet_attack_attribute(sheet, attribute)
  display(translate("MSG_PET_ATTRIBUTE_SET", attribute_to_string(attribute)))
end)

register_cmd("add-resource", "CMD_DESC_ADD_RESOURCE",
    function(name, min_value, max_value)
  local sheet = get_active_sheet()
  if not sheet then
    return display(translate "MSG_NO_ACTIVE_PROFILE")
  end
  if not name then
    return display(translate "MSG_REQUIRE_RESOURCE_NAME")
  end
  min_value = tonumber(min_value)
  max_value = tonumber(max_value)
  if not min_value or not max_value then
    return display(translate "MSG_INTEGER")
  end

  Sheet.add_resource(sheet, name, max_value, min_value, max_value)
  display(translate("MSG_RESOURCE_ADDED", name))
end)

register_cmd("remove-resource", "CMD_DESC_REMOVE_RESOURCE", function(name)
  local sheet = get_active_sheet()
  if not sheet then
    return display(translate "MSG_NO_ACTIVE_PROFILE")
  end
  if not name then
    return display(translate "MSG_REQUIRE_RESOURCE_NAME")
  end

  local success, msg = Sheet.remove_resource(sheet, name)
  display(success and translate("MSG_RESOURCE_REMOVED", name) or msg)
end)

register_cmd("set-resource", "CMD_DESC_SET_RESOURCE", function(name, value)
  local sheet = get_active_sheet()
  if not sheet then
    return display(translate "MSG_NO_ACTIVE_PROFILE")
  end
  if not name then
    return display(translate "MSG_REQUIRE_RESOURCE_NAME")
  end
  value = tonumber(value)
  if not value then
    return display(translate "MSG_INTEGER")
  end

  local success, msg = Sheet.set_resource_value(sheet, name, value)
  display(success and translate("MSG_RESOURCE_SET", name, value) or msg)
end)
