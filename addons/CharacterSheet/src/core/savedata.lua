--- Functionality for saving and loading from the saved variable(s).
-- @module Core.Savedata
local addon_name, CS = ...
local M = {}

local generate_uuid   = CS.Core.UUID.generate_uuid
local subscribe_event = CS.Core.Event.subscribe_event
local translate       = CS.Core.Locale.translate

--- Creates a data profile with a unique identifier.
-- Note that this function only creates the table representing the profile and
-- does not perform any side effects other than generating the identifier.
-- The profile is not automatically added to the profile database.
-- @tparam string name
-- The human-readable name for the profile.
-- @treturn table
-- A table representing the data profile.
local function initialize_profile(name)
  return {
    id   = generate_uuid(),
    name = name,
    data = {},
  }
end

--- Creates a fresh savedata table for the current addon version.
-- Note that this function only creates the table representing the savedata and
-- does not perform any side effects other than reading the current addon
-- version.
-- The savedata is not automatically saved to disk.
-- @treturn table
-- A table representing the savedata.
local function initialize_savedata()
  return {
    version    = GetAddOnMetadata(addon_name, "version"),
    settings   = {},
    profiles   = {},
    characters = {},
  }
end

--- Gets the addon's savedata table that is read from and stored to disk.
-- Note that, to avoid bugs and improve maintainability, the saved variable
-- should not be accessed directly from anywhere in the code!
-- Use this function to get it instead.
-- @treturn table
-- The addon's savedata.
local function get_savedata()
  CS_DEV_DB = CS_DEV_DB or initialize_savedata()
  return CS_DEV_DB
end

--- Clears all of the addon's save data.
-- This is of course a very destructive operation and one must have a very good
-- reason for calling this function.
local function reset_savedata()
  CS_DEV_DB = initialize_savedata()
end

--- Clears all of the addon's save data.
-- TODO: REMOVE THIS BEFORE RELEASE! This is only for debugging!
M.reset_savedata = reset_savedata

--- Gets the current player character's realm and name.
-- @treturn string
-- The character's name.
-- @treturn string
-- The character's realm.
function M.get_character_info()
  local name  = UnitName "player"
  local realm = GetRealmName()
  return name, realm
end

--- Gets an identifier for the current player character consisting of their
--- name and realm.
-- @treturn string
-- An identifier of the form "Character-Realm".
function M.get_character_id()
  local name, realm = M.get_character_info()
  return string.format("%s-%s", name, realm)
end

--- Gets the identifier for the active data profile for a character.
-- @tparam ?string character_id
-- The identifier for the character whose active profile to select.
-- If unspecified, the profile for the current player character will be
-- selected.
-- @treturn ?string
-- nil if the character doesn't have an active profile, otherwise the identifier
-- for the profile.
function M.get_profile_id(character_id)
  local savedata     = get_savedata()
  local character_id = character_id or M.get_character_id()
  local profile_id   = savedata.characters[character_id]
  return profile_id
end

--- Sets the currently active data profile used for reading and writing
--- profile-specific data.
-- This function errors if and only if the requested profile does not exist.
-- @tparam string profile_id
-- The identifier associated with the desired profile.
function M.set_active_profile(profile_id)
  local savedata = get_savedata()
  if not savedata.profiles[profile_id] then
    error(string.format(
      "Attempt to set active profile to non-existent profile with ID '%s'.",
      profile_id
    ))
  end
  local character_id = M.get_character_id()
  savedata.characters[character_id] = profile_id
end

--- Gets the data stored in a data profile.
-- This function errors if and only if the requested profile does not exist.
-- @tparam ?string profile_id
-- The identifier associated with the desired profile.
-- If unspecified, the data for the current player character's active profile
-- will be selected.
-- @treturn table
-- The table representing the data stored in the selected data profile.
function M.get_profile_data(profile_id)
  profile_id = profile_id or M.get_profile_id()
  if not profile_id then
    error(string.format(
      "Attempt to get the data for non-existent profile with ID '%s'.",
      profile_id
    ))
  end
  local savedata = get_savedata()
  return savedata.profiles[profile_id].data
end

--- Creates a data profile with a unique identifier.
-- The profile is created and then added to the profile database.
-- @tparam string name
-- The human-readable name for the profile.
-- @treturn string
-- The unique identifier for the newly created profile.
function M.create_profile(name)
  local savedata = get_savedata()
  local profile  = initialize_profile(name)
  savedata.profiles[profile.id] = profile
  return profile.id
end

subscribe_event("CS.SavedataLoading", function()
  local savedata = get_savedata()
  CS.Core.Util.dump "CS_DEV_DB"
end)

subscribe_event("CS.SavedataSaving", function()
  
end)

CS.Core.Savedata = M

-- TODO: Remove.
-- This table exists only as a reference to how the savedata is structured.
local example_savedata = {
  version  = "0.7.0",
  settings = {
    -- Global addon settings, not specific to a data profile.
  },
  profiles = {
    ["uuid"] = {
      id   = "uuid",
      name = "some profile",
      data = {
        -- The actual data used by the addon's logic.
      },
    },
  },
  characters = {
    ["Char-Realm"] = "uuid",
  },
}
