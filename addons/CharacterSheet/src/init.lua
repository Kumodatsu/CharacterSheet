local addon_name, CS = ...

CS.Core.Event.subscribe_event("WoW.AddonLoaded", function(...)
  print "Addon loaded!"
end)
