--- Event handling functionality.
-- @module Core.Event
local addon_name, CS = ...
local M = {}

-- A table whose keys are event identifiers (as strings) and whose values are
-- the callbacks subscribed to the events (as tables of functions).
local events = {}

--- Registers a custom event that other parts of the code or other addons can
--- listen to.
-- This function will error if and only if the supplied identifier is already
-- in use.
-- @tparam string event_id
-- A unique identifier for the event.
-- Listeners will use this identifier to subscribe to the event.
-- @treturn function
-- A function that can be called to fire the event, invoking all callbacks that
-- have subscribed to this event.
-- Any arguments passed to this function will be passed directly to these
-- callbacks.
function M.register_event(event_id)
  if events[event_id] then
    error(string.format(
      "The event '%s' has been registered multiple times.",
      event_id
    ))
  end
  events[event_id] = {}
  return function(...)
    for _, callback in ipairs(events[event_id]) do
      callback(...)
    end
  end
end

--- Subscribes to an event with the given callback function.
-- @tparam string event_id
-- The identifier for the event.
-- @tparam function callback
-- The callback to be invoked when the event is fired.
-- The function may receive arguments from the event.
function M.subscribe_event(event_id, callback)
  if not events[event_id] then
    error(string.format(
      "The event '%s' has not been registered.",
      event_id
    ))
  end
  table.insert(events[event_id], callback)
end

-- Listen to WoW events.
do
  local addon_loaded            = M.register_event "WoW.AddonLoaded"
  local player_logging_out      = M.register_event "WoW.PlayerLoggingOut"
  local system_message_received = M.register_event "WoW.SystemMessageReceived"

  -- An (invisible) WoW UI frame whose only purpose is to listen to WoW events.
  local event_listener = CreateFrame("Frame", "CS_EventFrame")
  event_listener:RegisterEvent "ADDON_LOADED"
  event_listener:RegisterEvent "PLAYER_LOGOUT"
  event_listener:RegisterEvent "CHAT_MSG_SYSTEM"

  function event_listener:OnEvent(event_id, arg1, ...)
    if event_id == "ADDON_LOADED" and arg1 == addon_name then
      addon_loaded(...)
    elseif event_id == "PLAYER_LOGOUT" then
      player_logging_out(arg1, ...)
    elseif event_id == "CHAT_MSG_SYSTEM" then
      system_message_received(arg1, ...)
    end
  end

  event_listener:SetScript("OnEvent", event_listener.OnEvent)
end

CS.Core.Event = M
