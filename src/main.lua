local addon_name, cs = ...

-- Handle loading/saving of stats from/to file
local frame_load_vars = CreateFrame("FRAME", "LoadStats")

local on_addon_loaded = function()
    cs.Charsheet.Stats = Stats or {}
end

local on_addon_unloading = function()
    Stats = cs.Charsheet.Stats
end

frame_load_vars:RegisterEvent("ADDON_LOADED")
frame_load_vars:RegisterEvent("PLAYER_LOGOUT")

frame_load_vars.OnEvent = function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addon_name then
        on_addon_loaded()
    elseif event == "PLAYER_LOGOUT" then
        on_addon_unloading()
    end
end

frame_load_vars:SetScript("OnEvent", frame_load_vars.OnEvent)
