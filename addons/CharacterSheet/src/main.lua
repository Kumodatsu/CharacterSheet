local _, CS = ...

local format = string.format
local insert = table.insert

local Savedata  = CS.Core.Savedata
local Sheet     = CS.Mechanics.Sheet
local Statblock = CS.Mechanics.Statblock

local Attribute = Statblock.Attribute

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

local function str_to_attribute(input)
  if not input then return nil end
  input = input:upper()
  return Attribute[input]
end

register_cmd("set", "CMD_DESC_SET", function(attribute_name, value)
  if not attribute_name then
    display(translate "MSG_REQUIRE_VALID_ATTRIBUTE")
    return
  end
  local attribute = str_to_attribute(attribute_name)
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
  local success, msg = Statblock.set_attribute(
    sheet.statblock, attribute, value
  )
  display(
    success and translate("MSG_STAT_SET", attribute_name:upper(), value) or msg
  )
end)


