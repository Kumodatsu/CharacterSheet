local _, cs = ...
local M = {}

local print = print

-- Stats will be loaded from file on addon load
M.Stats = {}

M.set_stat = function(name, value)
    value = tonumber(value)
    print(name .. " set to " .. value)
    M.Stats[name] = value
end

M.roll_stat = function(name, lower, upper)
    if name == nil then
        RandomRoll(1, 100)
        return
    end
    local v = M.Stats[name]
    if v == nil then
        print(name .. " is not one of your stats. Did you misspell it or forget to set it using /cs set?")
        return
    end
    lower = lower or 1
    upper = upper or 100
    RandomRoll(lower + v, upper + v)
end

M.show_stats = function()
    for stat, value in pairs(M.Stats) do
        print(stat .. ": " .. value)
    end
end

M.clear_stats = function(name)
    Stats = {}
end

cs.Commands.add_cmd("set", M.set_stat, [[
"/cs set name value" sets the stat with a given name to a given value.
For example: "/cs set atk 15"
]])

cs.Commands.add_cmd("roll", M.roll_stat, [[
"/cs roll name" rolls with the given stat modifier.
For example: "/cs roll atk"
]])

cs.Commands.add_cmd("stats", M.show_stats, [[
"/cs stats" shows the stats you have and their values.
]])

-- Handle loading/saving of stats from/to file
M.frame_load_vars = CreateFrame("FRAME", "LoadStats")

local on_addon_loaded = function()
    M.Stats = Stats or {}
end

local on_addon_unloading = function()
    Stats = M.Stats
end

M.frame_load_vars:RegisterEvent("ADDON_LOADED")
M.frame_load_vars:RegisterEvent("PLAYER_LEAVING_WORLD")

M.frame_load_vars.OnEvent = function(event, arg1)
    if event == "ADDON_LOADED" and arg1 == addon_name then
        on_addon_loaded()
    elseif event == "PLAYER_LEAVING_WORLD" then
        on_addon_unloading()
    end
end

cs.Charsheet = M
