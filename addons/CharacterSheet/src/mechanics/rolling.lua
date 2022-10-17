--- Functionality for making rolls with modifiers.
-- @module Mechanics.Rolling
local _, CS = ...
local M = {}

local insert          = table.insert
local remove          = table.remove

local register_event  = CS.Core.Event.register_event
local subscribe_event = CS.Core.Event.subscribe_event

-- Fired when a roll result has been received.
local on_rolled = register_event "CS.Rolled"

-- A Lua pattern that will match the random /roll result system message and
-- capture the roller's name, the roll value, and the lower and upper bound of
-- the roll range.
local roll_msg_pattern = RANDOM_ROLL_RESULT
  -- Find the string formatter and replace it with a capture group for
  -- alphanumeric characters to capture the roller's name.
  :gsub("%%s", "(%%w+)")
  -- Find the number formatters and replace them with capture groups for the
  -- numbers.
  :gsub("%%d", "(%%d+)")
  -- Escape the parentheses that are part of the message to prevent them from
  -- creating another capture group.
  :gsub("%(%(", "%%(%(")
  :gsub("%)%)", "%)%%)")

-- Table to hold information about rolls that the player has initiated, but
-- which have not yet received a response from the server.
local pending_rolls = {}

--- Checks if there are any pending rolls that match the given bounds and if so,
--- removes it from the pending rolls table and returns the associated tag.
-- @tparam number lower_bound
-- The lower bound on the roll.
-- @tparam number upper_bound
-- The upper bound on the roll.
-- @treturn ?any
-- The tag associated with the matching roll if it exists, otherwise nil.
local function take_matching_roll_tag(lower_bound, upper_bound)
  for i, pending_roll in ipairs(pending_rolls) do
    local is_match = (
      pending_roll.lower_bound == lower_bound and
      pending_roll.upper_bound == upper_bound
    )
    if is_match then
      local tag = pending_roll.tag
      remove(pending_rolls, i)
      return tag
    end
  end
  return nil
end

--- Performs a die roll.
-- The actual die roll is performed asynchronously by the WoW server, so this
-- function returns before the roll result is known.
-- To run code on receiving the roll result, subscribe to the CS.Rolled event.
-- The tag passed to this function will be passed on to the event so that one
-- can identify which invocation of this function caused the roll result.
-- @tparam number lower_bound
-- The lower bound on the roll.
-- @tparam number upper_bound
-- The upper bound on the roll.
-- @tparam ?any tag
-- Some data to tag this roll with.
-- When the server returns with the die result, it will be passed along with
-- this tag to the CS.Rolled event so that subscribers can decide how to handle
-- the roll.
function M.roll(lower_bound, upper_bound, tag)
  table.insert(pending_rolls, {
    lower_bound = lower_bound,
    upper_bound = upper_bound,
    tag         = tag,
  })
  RandomRoll(lower_bound, upper_bound)
end

-- Check for /roll result system messages from the player.
subscribe_event("WoW.SystemMessageReceived", function(msg)
  -- Attempt to extract roll information from the system message.
  local sender, raw_roll, lower_bound, upper_bound = msg:match(roll_msg_pattern)
  raw_roll    = tonumber(raw_roll)
  lower_bound = tonumber(lower_bound)
  upper_bound = tonumber(upper_bound)

  local player_name = UnitName "player"

  -- If any of these are missing, the system message was not a roll message.
  -- If it was a roll but didn't come from the player, we don't care about it.
  if not sender or not raw_roll or not lower_bound or not upper_bound
      or sender ~= player_name then
    return
  end

  -- Fire the CS.Rolled event, supplying it the roll's tag if there was any.
  local roll_tag = find_matching_roll_tag(lower_bound, upper_bound)
  on_rolled(roll_tag, raw_roll, lower_bound, upper_bound)
end)

CS.Mechanics.Rolling = M
