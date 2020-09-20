local addon_name, cs = ...
local M = {}

-- Will be loaded from file on addon load
M.Stats     = {}
M.CurrentHP = 16
M.Pets      = {}

-- Called when a stat or the power level is changed.
M.OnStatsChanged = cs.Event.create_event()
-- Called when the current or max HP is changed.
M.OnHPChanged    = cs.Event.create_event()

local clamp_hp = function()
    if M.CurrentHP > M.Stats:get_max_hp() then
        M.set_hp("max")
    end
    local pet_max_hp = M.Stats:get_pet_max_hp()
    for pet_name, pet in pairs(M.Pets) do
        if pet.CurrentHP > pet_max_hp then
            pet.CurrentHP = pet_max_hp
        end
    end
end

M.OnStatsChanged:add(clamp_hp)

M.set_stat = function(name, value)
    -- Check if the given value is a valid number
    value = tonumber(value)
    if value == nil or value < 0 or math.floor(value) ~= value then
        return cs.Output.Print "The value must be a positive integer."
    end
    -- Check if the given value is within the allowed range
    if value < cs.Stats.StatMinVal or value > cs.Stats.StatMaxVal then
        return cs.Output.Print(
            "The value must be in the range [%d, %d].",
            cs.Stats.StatMinVal,
            cs.Stats.StatMaxVal
        )
    end
    -- Check if the given stat is valid
    local mutable_stats = cs.Set.Set(cs.Stats.AttributeNames)
    name = name:upper()
    if not cs.Set.Contains(mutable_stats, name) then
        return cs.Output.Print("%s is not a valid stat.", name)
    end
    -- Modify the stat
    M.Stats[name] = value
    M.OnStatsChanged()
    if name == "CON" then
        M.OnHPChanged()
    end
    cs.Output.Print("%s set to %d", name, value)
end

M.roll_stat = function(name, mod)
    -- Roll bounds
    local lower = 1
    local upper = 20
    
    -- Natural d20 if no stat is specified
    if name == nil then
        cs.Roll.Roll(lower, upper)
        return
    end
    
    -- d20 + modifier if a stat is specified
    local roll_stats = cs.Set.Set {
        "STR", "DEX", "CON", "INT", "WIS", "CHA"
    }
    name = name:upper()
    if not cs.Set.Contains(roll_stats, name) then
        cs.Output.Print("%s is not a valid stat.", name)
        return
    end
    mod = (tonumber(mod) or 0) + M.Stats[name]
    cs.Roll.Roll(lower, upper, mod, name)
end

M.roll_heal = function(in_combat)
    in_combat = in_combat or "combat"
    if in_combat == "combat" then
        in_combat = true
    elseif in_combat == "safe" then
        in_combat = false
    else
        cs.Output.Print("Parameter must be one of combat, safe.")
        return
    end
    local mod   = M.Stats:get_heal_modifier()
    local lower = 1
    local upper = in_combat and 14 or 18
    cs.Roll.Roll(lower, upper, mod)
end

M.show_stats = function()
    cs.Output.Print("Power level: %s",
        cs.Stats.PowerLevel.to_string(M.Stats.Level))
    cs.Output.Print("HP: %d/%d", M.CurrentHP, M.Stats:get_max_hp())
    cs.Output.Print("STR: %d", M.Stats.STR)
    cs.Output.Print("DEX: %d", M.Stats.DEX)
    cs.Output.Print("CON: %d", M.Stats.CON)
    cs.Output.Print("INT: %d", M.Stats.INT)
    cs.Output.Print("WIS: %d", M.Stats.WIS)
    cs.Output.Print("CHA: %d", M.Stats.CHA)
end

M.set_level = function(level_name)
    local level = cs.Stats.PowerLevel.from_string(level_name)
    if level == nil then
        cs.Output.Print("%s is not a valid power level.", level_name)
        return
    end
    M.Stats.Level = level
    M.OnStatsChanged()
    cs.Output.Print("Power level set to %s.",
        cs.Stats.PowerLevel.to_string(level))
end

M.validate_stats = function()
    local valid, msg = M.Stats:validate()
    if valid then
        cs.Output.Print("Your stat block is valid.")
    else
        cs.Output.Print(msg)
    end
end

M.set_hp = function(value)
    if value == "max" then
        value = M.Stats:get_max_hp()
    else
        value = tonumber(value)
        if value == nil then
            cs.Output.Print("The given value must be a number or \"max\".")
            return
        end
    end
    if value < 0 or value > M.Stats:get_max_hp() or math.floor(value) ~= value then
        cs.Output.Print(
            "The given value must be a positive integer and may not exceed your max HP."
        )
        return
    end
    M.CurrentHP = value
    M.OnHPChanged()
    cs.Output.Print("HP set to %d.", value)
end

M.add_pet = function(name)
    if M.Pets[name] ~= nil then
        cs.Output.Print("You already have a pet named %s.", name)
        return
    end
    M.Pets[name] = {
        CurrentHP = M.Stats:get_pet_max_hp()
    }
    cs.Output.Print("Added pet named %s.", name)
end

M.show_pets = function()
    local pet_count  = 0
    local pet_max_hp = M.Stats:get_pet_max_hp()
    for pet_name, pet in pairs(M.Pets) do
        cs.Output.Print("%s: %d/%d HP", pet_name, pet.CurrentHP, pet_max_hp)
        pet_count = pet_count + 1
    end
    if pet_count == 0 then
        cs.Output.Print("You do not have any pets.")
    end
end

M.remove_pet = function(name)
    if name == nil or M.Pets[name] == nil then
        cs.Output.Print("You must specify one of your pets' names.")
        return
    end
    M.Pets[name] = nil
    cs.Output.Print("Removed pet %s.", name)
end

M.set_pet_hp = function(name, value)
    if name == nil or M.Pets[name] == nil then
        cs.Output.Print("You must specify one of your pets' names.")
        return
    end
    if value == "max" then
        value = M.Stats:get_pet_max_hp()
    else
        value = tonumber(value)
        if value == nil then
            cs.Output.Print("The given value must be a number or \"max\".")
            return
        end
    end
    if value < 0 or value > M.Stats:get_pet_max_hp() or math.floor(value) ~= value then
        cs.Output.Print(
            "The given value must be a positive integer and may not exceed your pet's max HP."
        )
        return
    end
    M.Pets[name].CurrentHP = value
    cs.Output.Print("%s's HP set to %d.", name, value)
end

cs.Commands.add_cmd("set", M.set_stat, [[
"/cs set <stat> <value>" sets the given stat to a given value.
For example: "/cs set str 15"
]])

cs.Commands.add_cmd("roll", M.roll_stat, [[
"/cs roll <stat>" rolls with the given stat modifier.
For example: "/cs roll str"
]])

cs.Commands.add_cmd("stats", M.show_stats, [[
"/cs stats" shows the stats you have and their values.
]])

cs.Commands.add_cmd("heal", M.roll_heal, [[
"/cs heal" and "/cs heal combat" perform a heal roll using a d14.
"/cs heal safe" performs a heal roll using a d18.
]])

cs.Commands.add_cmd("level", M.set_level, [[
"/cs level <level>" sets your character's power level to the specified level.
<level> must be one of novice, apprentice, adept, expert, master.
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
        cs.Output.Print("You must specify a valid number.")
        return
    end
    mode = mode or "up"
    mode = mode:lower()
    local half_x = x / 2
    if mode == "up" then
        cs.Output.Print(math.ceil(half_x))
    elseif mode == "down" then
        cs.Output.Print(math.floor(half_x))
    else
        cs.Output.Print("The rounding must be one of up, down.")
    end
end

cs.Commands.add_cmd("half", half, [[
    "/cs half <x> up" shows half the value of <x>, rounded up.
    "/cs half <x> down" shows half the value of <x>, rounded down.
    If no rounding is specified, values are rounded up.
]])

cs.Charsheet = M
