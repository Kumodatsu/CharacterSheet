local _, CS = ...

local format = string.format
local insert = table.insert

local Savedata  = CS.Core.Savedata
local Sheet     = CS.Mechanics.Sheet
local Statblock = CS.Mechanics.Statblock
local Rolling   = CS.Mechanics.Rolling

local Attribute = Statblock.Attribute

local attribute_to_string   = Statblock.attribute_to_string
local string_to_attribute   = Statblock.string_to_attribute
local power_level_to_string = Statblock.power_level_to_string
local string_to_power_level = Statblock.string_to_power_level

local display         = CS.Core.Util.display
local register_cmd    = CS.Core.Command.register_cmd
local subscribe_event = CS.Core.Event.subscribe_event
local translate       = CS.Core.Locale.translate

local function get_active_sheet()
  local data = Savedata.get_profile_data()
  data.sheet = data.sheet or Sheet.initialize_character_sheet()
  return data.sheet
end

subscribe_event("WoW.AddonLoaded", function()
  
end)

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

  local sheet        = get_active_sheet()
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

  local sheet   = get_active_sheet()
  local success = Sheet.set_power_level(sheet, level)
  display(translate("MSG_POWER_LEVEL_SET", power_level_to_string(level)))
end)

register_cmd("hp", "CMD_DESC_HP", function(value)
  local sheet = get_active_sheet()
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

  Rolling.roll(1, 20, {
    attribute = attribute,
    modifier  = tonumber(modifier),
  })
end)

register_cmd("heal", "CMD_DESC_HEAL", function(combat_state)
end)

register_cmd("stats", "CMD_DESC_STATS", function()
  local sheet = get_active_sheet()
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
  for _, resource in ipairs(sheet.resources) do
     display(
      "%1$s: %2$d/%3$d",
      resource.name,
      resource.value,
      resource.max_value
    )
  end
end)

subscribe_event("CS.Rolled", function(tag, raw_roll, lower_bound, upper_bound)
  if type(tag) ~= "table" then
    return
  end
  local roll = raw_roll
  local msg = tostring(roll)
  if tag.attribute then
    local sheet = get_active_sheet()
    roll = roll + sheet.statblock.attributes[tag.attribute]
    if tag.modifier then
      roll = roll + tag.modifier
    end
    msg = tostring(roll) .. " " .. attribute_to_string(tag.attribute)
  end
  if raw_roll == upper_bound then
    msg = msg .. " (" .. translate("NATURAL", upper_bound) .. ")"
  elseif raw_roll == lower_bound then
    msg = msg .. " (" .. translate("NATURAL", lower_bound) .. ")"
  end
  display(msg)
end)
