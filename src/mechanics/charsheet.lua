local addon_name, cs = ...
local M = {}

local print = print

-- Stats will be loaded from file on addon load
M.Stats = {}

M.set_stat = function(name, value)
    -- Check if the given value is a valid number
    value = tonumber(value)
    if value == nil or value < 0 or math.floor(value) ~= value then
        print("The value must be a positive integer.")
        return
    end
    -- Check if the given stat is valid
    local mutable_stats = cs.Set.Set {
        "STR", "DEX", "CON", "INT", "WIS", "CHA"
    }
    name = name:upper()
    if not cs.Set.Contains(mutable_stats, name) then
        print(name .. " is not a valid stat.")
        return
    end
    -- Modify the stat
    M.Stats[name] = value
    print(name .. " set to " .. value)
end

M.roll_stat = function(name)
    -- Roll bounds
    local lower = 1
    local upper = 20

    -- Natural d20 if no stat is specified
    if name == nil then
        RandomRoll(lower, upper)
        return
    end

    -- d20 + modifier if a stat is specified
    local roll_stats = cs.Set.Set {
        "STR", "DEX", "CON", "INT", "WIS", "CHA"
    }
    name = name:upper()
    if not cs.Set.Contains(roll_stats, name) then
        print(name .. " is not a valid stat.")
        return
    end
    local v = M.Stats[name]
    RandomRoll(lower + v, upper + v)
end

M.roll_heal = function()
    RandomRoll(1, 14)
end

M.show_stats = function()
    print("Max HP: " .. M.Stats:get_max_hp())
    print("STR: "    .. M.Stats.STR)
    print("DEX: "    .. M.Stats.DEX)
    print("CON: "    .. M.Stats.CON)
    print("INT: "    .. M.Stats.INT)
    print("WIS: "    .. M.Stats.WIS)
    print("CHA: "    .. M.Stats.CHA)
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

cs.Commands.add_cmd("heal", M.roll_heal, [[
"/cs heal" performs a heal roll using a d14.
]])

cs.Charsheet = M
