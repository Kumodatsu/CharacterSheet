local addon_name, CS = ...
local M = {}

-- Will be loaded from file on addon load
M.Stats     = {}
M.CurrentHP = 16
M.Pets      = {}
M.ActivePet = nil

-- Called when a stat or the power level is changed.
M.OnStatsChanged     = CS.Event.create_event()
-- Called when the current or max HP is changed.
M.OnHPChanged        = CS.Event.create_event()
-- Called when the currently active pet is changed.
M.OnActivePetChanged = CS.Event.create_event() 
-- Called when the list of pets or a pet's properties is/are changed.
M.OnPetsChanged      = CS.Event.create_event()

local clamp_hp = function()
    if M.CurrentHP > M.Stats:get_max_hp() then
        M.set_hp "max"
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
        return "The value must be a positive integer."
    end
    -- Check if the given value is within the allowed range
    if value < CS.Stats.StatMinVal or value > CS.Stats.StatMaxVal then
        return string.format(
            "The value must be in the range [%d, %d].",
            CS.Stats.StatMinVal,
            CS.Stats.StatMaxVal
        )
    end
    -- Check if the given stat is valid
    local mutable_stats = CS.Set.Set(CS.Stats.AttributeNames)
    name = name:upper()
    if not CS.Set.Contains(mutable_stats, name) then
        return string.format("%s is not a valid stat.", name)
    end
    -- Modify the stat
    M.Stats[name] = value
    M.OnStatsChanged()
    if name == "CON" then
        M.OnHPChanged()
    end
    return string.format("%s set to %d", name, value)
end

local cmd_set_stat = function(name, value)
    local output = M.set_stat(name, value)
    if output then CS.Output.Print(output) end
end

M.roll_stat = function(name, mod)
    -- Roll bounds
    local lower = 1
    local upper = 20
    
    -- Natural d20 if no stat is specified
    if name == nil then
        CS.Roll.Roll(lower, upper)
        return
    end
    
    -- d20 + modifier if a stat is specified
    local roll_stats = CS.Set.Set {
        "STR", "DEX", "CON", "INT", "WIS", "CHA"
    }
    name = name:upper()
    if not CS.Set.Contains(roll_stats, name) then
        CS.Output.Print("%s is not a valid stat.", name)
        return
    end
    mod = (tonumber(mod) or 0) + M.Stats[name]
    CS.Roll.Roll(lower, upper, mod, name)
end

M.roll_heal = function(in_combat)
    in_combat = in_combat or "combat"
    if in_combat == "combat" then
        in_combat = true
    elseif in_combat == "safe" then
        in_combat = false
    else
        CS.Output.Print("Parameter must be one of combat, safe.")
        return
    end
    local mod   = M.Stats:get_heal_modifier()
    local lower = 1
    local upper = in_combat and 14 or 18
    CS.Roll.Roll(lower, upper, mod)
end

M.pet_attack = function(name)
    name = name or M.ActivePet
    if not name or not M.Pets[name] then
        return CS.Output.Print "You must have a pet active or specify one of your pets' names."
    end
    local pet = M.Pets[name]
    CS.Roll.Roll(1, 20, M.Stats[pet.Attack], pet.Attack, CS.Math.half)
end

M.set_pet_attack_attribute = function(attrib, name)
    if type(attrib) ~= "string" then
        return CS.Output.Print "You must specify a valid stat attribute."
    end
    attrib = attrib:upper()
    if not CS.Stats.is_valid_attribute(attrib) then
        return CS.Output.Print "You must specify a valid stat attribute."
    end
    name = name or M.ActivePet
    if not name then
        return CS.Output.Print "You must have a pet active or specify one of your pets' names."
    end
    if M.Pets[name] then
        M.Pets[name].Attack = attrib
        M.OnPetsChanged()
        if name == M.ActivePet then
            M.OnActivePetChanged()
        end
    else
        return CS.Output.Print("You don't have a pet named %s.", name)
    end
    CS.Output.Print("Pet attack attribute set to %s.", attrib)
end

M.show_stats = function()
    CS.Output.Print("Power level: %s",
        CS.Stats.PowerLevel.to_string(M.Stats.Level))
    CS.Output.Print("HP: %d/%d", M.CurrentHP, M.Stats:get_max_hp())
    if M.ActivePet then
        local pet = M.Pets[M.ActivePet]
        CS.Output.Print("%s HP: %d/%d", pet.Name, pet.CurrentHP,
            M.Stats:get_pet_max_hp())
    end
    CS.Output.Print("STR: %d", M.Stats.STR)
    CS.Output.Print("DEX: %d", M.Stats.DEX)
    CS.Output.Print("CON: %d", M.Stats.CON)
    CS.Output.Print("INT: %d", M.Stats.INT)
    CS.Output.Print("WIS: %d", M.Stats.WIS)
    CS.Output.Print("CHA: %d", M.Stats.CHA)
end

M.set_level = function(level_name)
    local level = CS.Stats.PowerLevel.from_string(level_name)
    if level == nil then
        return string.format("%s is not a valid power level.", level_name)
    end
    M.Stats.Level = level
    M.OnStatsChanged()
    M.OnHPChanged()
    return string.format("Power level set to %s.",
        CS.Stats.PowerLevel.to_string(level))
end

local cmd_set_level = function(level_name)
    local output = M.set_level(level_name)
    if output then CS.Output.Print(output) end
end

M.validate_stats = function()
    local valid, msg = M.Stats:validate()
    if valid then
        CS.Output.Print "Your stat block is valid."
    else
        CS.Output.Print(msg)
    end
end

M.set_hp = function(value)
    if value == "max" then
        value = M.Stats:get_max_hp()
    else
        value = tonumber(value)
        if value == nil then
            return "The given value must be a number or \"max\"."
        end
    end
    if value < 0 or value > M.Stats:get_max_hp() or math.floor(value) ~= value then
        return "The given value must be a positive integer and may not exceed your max HP."
    end
    M.CurrentHP = value
    M.OnHPChanged()
    return string.format("HP set to %d.", value)
end

local cmd_set_hp = function(value)
    local output = M.set_hp(value)
    if output then CS.Output.Print(output) end
end

M.increment_hp = function(number)
    number = number or 1
    M.set_hp(M.CurrentHP + number)
end

M.decrement_hp = function(number)
    number = number or 1
    M.set_hp(M.CurrentHP - number)
end

M.add_pet = function(name)
    if type(name) ~= "string" then
        return CS.Output.Print "You must specify a name for your pet."
    end
    local first_pet = CS.Table.is_empty(M.Pets)
    if M.Pets[name] ~= nil then
        return CS.Output.Print("You already have a pet named %s.", name)
    end
    M.Pets[name] = {
        Name      = name,
        CurrentHP = M.Stats:get_pet_max_hp(),
        Attack    = "CHA"
    }
    M.OnPetsChanged()
    if first_pet then
        M.set_active_pet(name)
    end
    CS.Output.Print("Added pet named %s.", name)
end

M.show_pets = function()
    local pet_count  = 0
    local pet_max_hp = M.Stats:get_pet_max_hp()
    for pet_name, pet in pairs(M.Pets) do
        local active = M.ActivePet == pet_name and " (active)" or ""
        CS.Output.Print("%s: %d/%d HP%s", pet_name, pet.CurrentHP, pet_max_hp,
            active)
        pet_count = pet_count + 1
    end
    if pet_count == 0 then
        CS.Output.Print "You do not have any pets."
    end
end

M.remove_pet = function(name)
    if name == nil or M.Pets[name] == nil then
        return CS.Output.Print "You must specify one of your pets' names."
    end
    M.Pets[name] = nil
    if M.ActivePet == name then
        M.set_active_pet(nil)
    end
    M.OnPetsChanged()
    CS.Output.Print("Removed pet %s.", name)
end

M.set_pet_hp = function(value, name)
    name = name or M.ActivePet
    if name == nil or M.Pets[name] == nil then
        return "You must have a pet active or specify one of your pets' names."
    end
    if value == "max" then
        value = M.Stats:get_pet_max_hp()
    else
        value = tonumber(value)
        if value == nil then
            return "The given value must be a number or \"max\"."
        end
    end
    if value < 0 or value > M.Stats:get_pet_max_hp() or math.floor(value) ~= value then
        return "The given value must be a positive integer and may not exceed your pet's max HP."
    end
    M.Pets[name].CurrentHP = value
    M.OnPetsChanged()
    if name == M.ActivePet then
        M.OnActivePetChanged()
    end
    return string.format("%s's HP set to %d.", name, value)
end

local cmd_set_pet_hp = function(value, name)
    local output = M.set_pet_hp(value, name)
    if output then CS.Output.Print(output) end
end

M.increment_pet_hp = function(number, name)
    number = number or 1
    name   = name or M.ActivePet
    if not M.pet_exists(name) then
        return CS.Output.Print "You must have a pet active or specify one of your pets' names."
    end
    local pet = M.Pets[name]
    M.set_pet_hp(pet.CurrentHP + number, name)
end

M.decrement_pet_hp = function(number, name)
    number = number or 1
    M.increment_pet_hp(-number, name)
end

M.set_active_pet = function(name)
    if name == nil or M.pet_exists(name) then
        local had_active = M.ActivePet ~= nil
        M.ActivePet = name
        M.OnActivePetChanged()
        if name then
            CS.Output.Print("%s is now your active pet.", name)
        elseif had_active then
            CS.Output.Print "You no longer have an active pet."
        else
            CS.Output.Print "You must specify a pet's name."
        end
    else
        CS.Output.Print("You do not have a pet named \"%s\".", name)
    end
end

M.active_pet = function()
    if not M.ActivePet then return nil end
    return M.Pets[M.ActivePet]
end

M.pet_exists = function(name)
    return name ~= nil and M.Pets[name] ~= nil
end

CS.Commands.add_cmd("set", cmd_set_stat, [[
"/cs set <stat> <value>" sets the given stat to a given value.
For example: "/cs set str 15"
]])

CS.Commands.add_cmd("roll", M.roll_stat, [[
"/cs roll <stat>" rolls with the given stat modifier.
For example: "/cs roll str"
]])

CS.Commands.add_cmd("stats", M.show_stats, [[
"/cs stats" shows the stats you have and their values.
]])

CS.Commands.add_cmd("heal", M.roll_heal, [[
"/cs heal" and "/cs heal combat" perform a heal roll using a d14.
"/cs heal safe" performs a heal roll using a d18.
]])

CS.Commands.add_cmd("level", cmd_set_level, [[
"/cs level <level>" sets your character's power level to the specified level.
<level> must be one of novice, apprentice, adept, expert, master.
]])

CS.Commands.add_cmd("validate", M.validate_stats, [[
"/cs validate" checks whether your stat block is valid.
]])

CS.Commands.add_cmd("hp", cmd_set_hp, [[
"/cs hp max" sets your current HP to your max HP.
"/cs hp <value>" sets your current HP to the given value.
]])

CS.Commands.add_cmd("addpet", M.add_pet, [[
"/cs addpet <name>" adds a pet with the given name.
]])

CS.Commands.add_cmd("pets", M.show_pets, [[
"/cs pets" shows a list of your pets and their stats.
]])

CS.Commands.add_cmd("setpet", M.set_active_pet, [[
"/cs setpet" deactivates your pet.
"/cs setpet <name>" sets the pet with the given name to be your active pet.
]])

CS.Commands.add_cmd("removepet", M.remove_pet, [[
"/cs removepet <name>" removes the pet with the given name.
]])

CS.Commands.add_cmd("pethp", cmd_set_pet_hp, [[
"/cs pethp max" sets your active pet's current HP to their max HP.
"/cs pethp <value>" sets your active pet's current HP to the given value.
"/cs pethp max <name>" sets the pet with the given name's current HP to their max HP.
"/cs pethp <value> <name>" sets the pet with the given name's current HP to the given value.
]])

CS.Commands.add_cmd("petatk", M.pet_attack, [[
"/cs petatk" performs a pet attack roll and displays the final damage number.
]])

CS.Commands.add_cmd("setpetatk", M.set_pet_attack_attribute, [[
"/cs setpetatk <attribute>" sets your pet attack attribute to the given attribute.
]])

-- Temporary helper function to half an integer value.
local half = function(x, mode)
    x = tonumber(x)
    if x == nil then
        CS.Output.Print("You must specify a valid number.")
        return
    end
    mode = mode or "up"
    mode = mode:lower()
    local half_x = x / 2
    if mode == "up" then
        CS.Output.Print(math.ceil(half_x))
    elseif mode == "down" then
        CS.Output.Print(math.floor(half_x))
    else
        CS.Output.Print("The rounding must be one of up, down.")
    end
end

CS.Commands.add_cmd("half", half, [[
    "/cs half <x> up" shows half the value of <x>, rounded up.
    "/cs half <x> down" shows half the value of <x>, rounded down.
    If no rounding is specified, values are rounded up.
]])

CS.Charsheet = M
