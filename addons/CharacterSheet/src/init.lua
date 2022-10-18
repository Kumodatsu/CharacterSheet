local addon_name, CS = ...

CS.Core.Event.subscribe_event("WoW.AddonLoaded", function(...)
  
end)

-- Global accessor to the addon's public functionality.
CS_API = CS
