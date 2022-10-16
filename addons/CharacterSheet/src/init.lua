local addon_name, CS = ...

CS.Core.Events.subscribe_event("WoW.AddonLoaded", function(...)
  print "Addon loaded!"
end)
