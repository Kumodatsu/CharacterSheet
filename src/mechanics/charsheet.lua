local addon_name, cs = ...
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
        RandomRoll(1, 20)
        return
    end
    local v = M.Stats[name]
    if v == nil then
        print(name .. " is not one of your stats. Did you misspell it or forget to set it using /cs set?")
        return
    end
    lower = lower or 1
    upper = upper or 20
    RandomRoll(lower + v, upper + v)
end

M.roll_heal = function()
    RandomRoll(1, 14)
end

M.show_stats = function()
    local n = 0
    for stat, value in pairs(M.Stats) do
        print(stat .. ": " .. value)
        n = n + 1
    end
    if n == 0 then
        print("Your stat block is empty.")
    end
end

M.clear_stats = function(name)
    if name == nil then
        for k, _ in pairs(M.Stats) do
            M.Stats[k] = nil
        end
        print("Your stat block has been cleared.")
        return
    end
    local v = M.Stats[name]
    if v == nil then
        print(name .. " is not one of your stats. Did you misspell it or forget to set it using /cs set?")
        return
    end
    M.Stats[name] = nil
    print(name .. " has been removed from your stats.")
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

cs.Commands.add_cmd("clear", M.clear_stats, [[
"/cs clear" clears your entire stat block.
"/cs clear name" clears the stat with the given name from your stat block.
]])

cs.Commands.add_cmd("heal", M.roll_heal, [[
"/cs heal" performs a heal roll using a d14.
]])

cs.Charsheet = M
