local addon_name, cs = ...
local M = {}

local print = print

-- Will be loaded from file on addon load
M.Stats     = {}
M.CurrentHP = 16
M.Pets      = {}

-- Called when a stat or the power level is changed.
local on_stats_changed = function()
    if M.CurrentHP > M.Stats:get_max_hp() then
        M.CurrentHP = M.Stats:get_max_hp()
    end
    local pet_max_hp = M.Stats:get_pet_max_hp()
    for pet_name, pet in pairs(M.Pets) do
        if pet.CurrentHP > pet_max_hp then
            pet.CurrentHP = pet_max_hp
        end
    end
end

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
    on_stats_changed()
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
    local mod = M.Stats:get_heal_modifier()
    RandomRoll(mod + 1, mod + 14)
end

M.show_stats = function()
    print("Power level: " .. cs.Stats.PowerLevel.to_string(M.Stats.Level))
    print("HP: " .. M.CurrentHP .. "/" .. M.Stats:get_max_hp())
    print("STR: " .. M.Stats.STR)
    print("DEX: " .. M.Stats.DEX)
    print("CON: " .. M.Stats.CON)
    print("INT: " .. M.Stats.INT)
    print("WIS: " .. M.Stats.WIS)
    print("CHA: " .. M.Stats.CHA)
end

M.set_level = function(level_name)
    local level = cs.Stats.PowerLevel.from_string(level_name)
    if level == nil then
        print(level_name .. " is not a valid power level.")
        return
    end
    M.Stats.Level = level
    on_stats_changed()
    print ("Power level set to " .. cs.Stats.PowerLevel.to_string(level) .. ".")
end

M.validate_stats = function()
    local valid, msg = M.Stats:validate()
    if valid then
        print("Your stat block is valid.")
    else
        print(msg)
    end
end

M.set_hp = function(value)
    if value == "max" then
        value = M.Stats:get_max_hp()
    else
        value = tonumber(value)
        if value == nil then
            print("The given value must be a number or \"max\".")
            return
        end
    end
    if value < 0 or value > M.Stats:get_max_hp() or math.floor(value) ~= value then
        print("The given value must be a positive integer and may not exceed your max HP.")
        return
    end
    M.CurrentHP = value
    print("HP set to " .. value .. ".")
end

M.add_pet = function(name)
    if M.Pets[name] ~= nil then
        print("You already have a pet named " .. name .. ".")
        return
    end
    M.Pets[name] = {
        CurrentHP = M.Stats:get_pet_max_hp()
    }
    print("Added pet named " .. name .. ".")
end

M.show_pets = function()
    local pet_count  = 0
    local pet_max_hp = M.Stats:get_pet_max_hp()
    for pet_name, pet in pairs(M.Pets) do
        print(pet_name .. ": " .. pet.CurrentHP .. "/" .. pet_max_hp .. " HP")
        pet_count = pet_count + 1
    end
    if pet_count == 0 then
        print("You do not have any pets.")
    end
end

M.remove_pet = function(name)
    if name == nil or M.Pets[name] == nil then
        print("You must specify one of your pets' names.")
        return
    end
    M.Pets[name] = nil
    print("Removed pet " .. name)
end

M.set_pet_hp = function(name, value)
    if name == nil or M.Pets[name] == nil then
        print("You must specify one of your pets' names.")
        return
    end
    if value == "max" then
        value = M.Stats:get_pet_max_hp()
    else
        value = tonumber(value)
        if value == nil then
            print("The given value must be a number or \"max\".")
            return
        end
    end
    if value < 0 or value > M.Stats:get_pet_max_hp() or math.floor(value) ~= value then
        print("The given value must be a positive integer and may not exceed your pet's max HP.")
        return
    end
    M.Pets[name].CurrentHP = value
    print(name .. "'s HP set to " .. value .. ".")
end

cs.Commands.add_cmd("set", M.set_stat, [[
"/cs set <name> <value>" sets the stat with a given name to a given value.
For example: "/cs set str 15"
]])

cs.Commands.add_cmd("roll", M.roll_stat, [[
"/cs roll <name>" rolls with the given stat modifier.
For example: "/cs roll str"
]])

cs.Commands.add_cmd("stats", M.show_stats, [[
"/cs stats" shows the stats you have and their values.
]])

cs.Commands.add_cmd("heal", M.roll_heal, [[
"/cs heal" performs a heal roll using a d14.
]])

cs.Commands.add_cmd("level", M.set_level, [[
"/cs level <name>" sets your character's power level to the specified level.
<name> must be one of novice, apprentice, adept, expert, master.
]])

cs.Commands.add_cmd("validate", M.validate_stats, [[
"/cs validate" checks whether your stat block is valid.
]])

cs.Commands.add_cmd("hp", M.set_hp, [[
"/cs hp max" sets your current HP to your max HP.
"/cs hp <value>" sets your current HP to the given value.
]])

cs.Commands.add_cmd("addpet", M.add_pet, [[
"/cs addpet <name>" adds a pet with the given name.
]])

cs.Commands.add_cmd("pets", M.show_pets, [[
"/cs pets" shows a list of your pets and their stats.
]])

cs.Commands.add_cmd("removepet", M.remove_pet, [[
"/cs removepet <name>" removes the pet with the given name.
]])

cs.Commands.add_cmd("pethp", M.set_pet_hp, [[
"/cs pethp <name> max" sets the pet with the given name's current HP to their max HP.
"/cs pethp <name> <value>" sets the pet with the given name's current HP to the given value.
]])

-- Temporary helper function to half an integer value.
local half = function(x, mode)
    x = tonumber(x)
    if x == nil then
        print("You must specify a valid number.")
        return
    end
    mode = mode or "up"
    mode = mode:lower()
    local half_x = x / 2
    if mode == "up" then
        print(math.ceil(half_x))
    elseif mode == "down" then
        print(math.floor(half_x))
    else
        print("The rounding must be one of up, down.")
    end
end

cs.Commands.add_cmd("half", half, [[
    "/cs half <x> up" shows half the value of <x>, rounded up.
    "/cs half <x> down" shows half the value of <x>, rounded down.
    If no rounding is specified, values are rounded up.
]])

cs.Charsheet = M
