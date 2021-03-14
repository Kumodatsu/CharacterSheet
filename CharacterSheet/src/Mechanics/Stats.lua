--- Main logic for the system's mechanics.
-- @module CS.Mechanics.Stats
-- @alias M

local addon_name, CS = ...
CS.Mechanics = CS.Mechanics or {}
CS.Mechanics.Stats = {}

local M = CS.Mechanics.Stats

local T = CS.Locale.GetLocaleTranslations()

local RollType = CS.Mechanics.Roll.RollType

--- Minimum value for an attribute.
M.StatMinValue      =  5
--- Maximum value for an attribute.
M.StatMaxValue      = 24
--- The maximum value on the die to use for heal rolls when out of combat.
M.SafeHealRollDie   = 14
--- The maximum value on the die to use for heal rolls when in combat.
M.CombatHealRollDie = 10
--- The HP value at which one gets knocked out.
M.KnockOutValue     = -5

--- Called when a stat or the power level is changed.
CS.Events.OnStatsChanged    = CS.Event.create_event()
--- Called when the current or max HP is changed.
CS.Events.OnHPChanged       = CS.Event.create_event()
--- Called when the pet is toggled on or off.
CS.Events.OnPetToggled      = CS.Event.create_event()
--- Called when the pet HP or pet attack attribute is changed.
CS.Events.OnPetChanged      = CS.Event.create_event()
--- Called when a resource is added, removed or changed.
CS.Events.OnResourceChanged = CS.Event.create_event()

local attribute_names = { "STR", "DEX", "CON", "INT", "WIS", "CHA" }

--- An enumeration of all power levels.
M.PowerLevel = {
    Novice     = 1, -- Novice level (76 SP, +2 HP)
    Apprentice = 2, -- Apprentice level (78 SP, +4 HP)
    Adept      = 3, -- Adept level (80 SP, +6 HP)
    Expert     = 4, -- Expert level (82 SP, +8 HP)
    Master     = 5  -- Master level (84 SP, +10 HP)
}

--[[--
    Checks if a string is a valid attribute name.
    @tparam string name The string to check.
    @treturn boolean true iff the string is a valid short attribute name in
    uppercase, false otherwise.
]]
M.is_valid_attribute = function(name)
    for _, attrib in ipairs(attribute_names) do
        if attrib == name then return true end
    end
    return false
end

--[[--
    Gets the names of all attributes.
    @treturn table The short names of all attributes in uppercase.
]]
M.get_attribute_names = function()
    return attribute_names
end

--[[--
    Gets the name of a power level.
    @tparam number level The power level.
    @treturn string The name of the power level.
]]
M.power_level_name = function(level)
    return ({
        "Novice", "Apprentice", "Adept", "Expert", "Master"
    })[level]
end

--[[--
    Gets the power level given its name.
    @tparam string name The power level's name.
    @treturn[1] number The power level that corresponds to the name.
    @treturn[2] nil nil if the name doesn't correspond to a power level.
]]
M.power_level_from_name = function(name)
    name = name:lower()
    return ({
        ["novice"]     = 1,
        ["apprentice"] = 2,
        ["adept"]      = 3,
        ["expert"]     = 4,
        ["master"]     = 5
    })[name]
end

--[[--
    The SP bonus corresponding to a power level.
    The SP bonus that a character of a certain power level has. This does not
    count the standard 60 that every character gets.
    @tparam number level The power level.
    @treturn number The level's SP bonus.
]]
M.get_sp_bonus = function(level)
    return 14 + 2 * level
end

--[[--
    The HP bonus corresponding to a power level.
    The HP bonus that a character of a certain power level gets on top of their
    constitution value.
    @tparam number level The power level.
    @treturn number The level's HP bonus.
]]
M.get_hp_bonus = function(level)
    return 2 * level
end

--[[--
    Creates a stat block which has a power level and a value for each attribute.
    @treturn table The stat block.
]]
M.create_stat_block = function()
    local stat_block = {
        STR   = str   or 13,
        DEX   = dex   or 13,
        CON   = con   or 13,
        INT   = int   or 13,
        WIS   = wis   or 13,
        CHA   = cha   or 13,
        Level = level or M.PowerLevel.Apprentice
    }
    return stat_block
end

--[[--
    Gets an iterator over the attribute names and values of a stat block.
    @tparam table stat_block The stat block.
    @treturn function An iterator of string, number pairs of the stat block's
        attribute names and the values corresponding to those attributes.
]]
M.get_attributes = function(stat_block)
    local index = 1
    return function()
        local attribute_name = attribute_names[index]
        local value          = stat_block[attribute_name]
        index = index + 1
        return attribute_name, value
    end
end

--[[--
    Validates a stat block.
    Checks if a stat block's attribute values are valid for its power level.
    @tparam table stat_block The stat block.
    @treturn boolean true iff the stat block is valid, false otherwise.
    @treturn ?string A message describing why a stat block is invalid or that it
        still has unspent SP.
]]
M.validate = function(stat_block)
    for attribute, value in M.get_attributes(stat_block) do
        if value < M.StatMinValue or value > M.StatMaxValue then
            return false, T.MSG_ATTRIB_RANGE(attribute, M.StatMinValue,
                M.StatMaxValue)
        end
    end
    local remaining_sp = M.get_remaining_sp(stat_block)
    if remaining_sp < 0 then
        return false, T.MSG_TOO_MANY_SP(-remaining_sp)
    elseif remaining_sp > 0 then
        return true, T.MSG_UNSPENT_SP(remaining_sp)
    end
    return true
end

--[[--
    Gets the maximum HP for a stat block.
    @tparam table stat_block The stat block.
    @treturn number The maximum HP value.
]]
M.get_max_hp = function(stat_block)
    return stat_block.CON + M.get_hp_bonus(stat_block.Level)
end

--[[--
    Gets the maximum pet HP for a stat block.
    @tparam table stat_block The stat block.
    @treturn number The maximum pet HP value.
]]
M.get_pet_max_hp = function(stat_block)
    return math.ceil(M.get_max_hp(stat_block) / 2)
end

--[[--
    Gets the total number of SP that a stat block may have with its power level.
    @tparam table stat_block The stat block.
    @treturn number The total number of SP allowed for the stat block.
]]
M.get_potential_sp = function(stat_block)
    return 60 + M.get_sp_bonus(stat_block.Level)
end

--[[--
    Gets the total number of SP spent in a stat block.
    @tparam table stat_block The stat block.
    @treturn number The total number of SP spent in the stat block.
]]
M.get_total_sp = function(stat_block)
    local total = 0
    for _, value in M.get_attributes(stat_block) do
        total = total + value
    end
    return total
end

--[[--
    Gets the total number of SP that may still be spent in a stat block.
    @tparam table stat_block The stat block.
    @treturn number The total number of SP that may still be spent in the stat
        block.
]]
M.get_remaining_sp = function(stat_block)
    return M.get_potential_sp(stat_block) - M.get_total_sp(stat_block)
end

--[[--
    Gets the heal modifier for a stat block.
    @tparam table stat_block The stat block.
    @treturn number The heal modifier, i.e. the value that is added on top of
        heal rolls.
]]
M.get_heal_modifier = function(stat_block)
    return math.floor(math.max(0, stat_block.CHA - 10) / 2)
end

--[[--
    Creates a character sheet.
    @treturn table The character sheet.
]]
M.create_character_sheet = function()
    local sheet = {
        StatBlock    = M.create_stat_block(),
        PetActive    = false,
        PetAttribute = "CHA"
    }
    sheet.HP    = M.get_max_hp(sheet.StatBlock)
    sheet.PetHP = M.get_pet_max_hp(sheet.StatBlock)
    return sheet
end

--[[--
    Clamps the current HP on a character sheet between the knock out value and
    the max HP.
    @tparam table sheet The character sheet.
]]
M.clamp_hp = function(sheet)
    local hp_max = M.get_max_hp(sheet.StatBlock)
    if sheet.HP > hp_max then
        M.set_hp(sheet, hp_max)
    end
    local pet_hp_max = M.get_pet_max_hp(sheet.StatBlock)
    if sheet.PetHP > pet_hp_max then
        M.set_pet_hp(pet_hp_max)
    end
end

--[[--
    Sets an attribute on a character sheet to a value if valid.
    @tparam table sheet The character sheet.
    @tparam string attribute The name of the attribute.
    @tparam number value The value to set the attribute to.
    @treturn boolean true iff the assignment was successful, false otherwise.
    @treturn ?string A message describing why the assignment is invalid.
]]
M.set_stat = function(sheet, attribute, value)
    if value < M.StatMinValue or value > M.StatMaxValue then
        return false, T.MSG_RANGE(M.StatMinValue, M.StatMaxValue)
    end
    local old_value = sheet.StatBlock[attribute]
    sheet.StatBlock[attribute] = value
    local valid, msg = M.validate(sheet.StatBlock)
    if not valid then
        sheet.StatBlock[attribute] = old_value
        return false, msg
    end
    CS.Events.OnStatsChanged()
    if attribute == "CON" then
        M.clamp_hp(sheet)
        CS.Events.OnHPChanged()
    end
    return true
end

--[[--
    Sets the attribute to be used for pet attacks on the character sheet.
    @tparam table sheet The character sheet.
    @tparam string attribute The name of the attribute.
    @treturn boolean true
]]
M.set_pet_attribute = function(sheet, attribute)
    sheet.PetAttribute = attribute
    CS.Events.OnPetChanged()
    return true
end

--[[--
    Activates or deactives the pet on a character sheet. 
    @tparam table sheet The character sheet.
    @tparam ?boolean active true to activate the pet, false to deactive the pet.
        If not specified, the pet is toggled.
]]
M.toggle_pet = function(sheet, active)
    if active == nil then
        active = not sheet.PetActive
    end
    sheet.PetActive = active
    CS.Events.OnPetToggled(active)
end

--[[--
    Sets the power level on a character sheet.
    If the new level causes the sheet to have too many SP spent, attribute
    values will be reduced until the number of SP is valid again.
    @tparam table sheet The character sheet.
    @tparam number level The power level.
    @treturn boolean true
]]
M.set_level = function(sheet, level)
    sheet.StatBlock.Level = level
    -- If the change in level causes one to have fewer SP than they have spent,
    -- reduce stats until the number of SP spent is valid again
    local sp = M.get_remaining_sp(sheet.StatBlock)
    for _, attribute in ipairs(attribute_names) do
        while sheet.StatBlock[attribute] > M.StatMinValue and sp < 0 do
            sheet.StatBlock[attribute] = sheet.StatBlock[attribute] - 1
            sp = sp + 1
        end
    end
    M.clamp_hp(sheet)
    CS.Events.OnStatsChanged()
    CS.Events.OnHPChanged()
    return true
end

--[[--
    Sets the current HP on a character sheet to a value if possible.
    @tparam table sheet The character sheet.
    @tparam number hp The HP value.
    @treturn boolean true iff the assignment was successful, false otherwise.
    @treturn ?string A message describing why the assignment is invalid.
]]
M.set_hp = function(sheet, hp)
    if hp < M.KnockOutValue or hp > M.get_max_hp(sheet.StatBlock) then
        return false, T.MSG_SET_HP_ALLOWED_VALUES
    end
    sheet.HP = hp
    CS.Events.OnHPChanged()
    return true
end

--[[--
    Increases the current HP value on a character sheet by a given number.
    @tparam table sheet The character sheet.
    @tparam[opt=1] number number The number by which to increase the HP value.
    @treturn boolean true iff the assignment was successful, false otherwise.
    @treturn ?string A message describing why the assignment is invalid.
]]
M.increment_hp = function(sheet, number)
    number = number or 1
    return M.set_hp(sheet, sheet.HP + number)
end

--[[--
    Decreases the current HP value on a character sheet by a given number.
    @tparam table sheet The character sheet.
    @tparam[opt=1] number number The number by which to decrease the HP value.
    @treturn boolean true iff the assignment was successful, false otherwise.
    @treturn ?string A message describing why the assignment is invalid.
]]
M.decrement_hp = function(sheet, number)
    number = number or 1
    return M.set_hp(sheet, sheet.HP - number)
end

--[[--
    Sets the current pet HP on a character sheet to a value if possible.
    @tparam table sheet The character sheet.
    @tparam number hp The pet HP value.
    @treturn boolean true iff the assignment was successful, false otherwise.
    @treturn ?string A message describing why the assignment is invalid.
]]
M.set_pet_hp = function(sheet, hp)
    if hp < M.KnockOutValue or hp > M.get_pet_max_hp(sheet.StatBlock) then
        return false, T.MSG_SET_PET_HP_ALLOWED_VALUES
    end
    sheet.PetHP = hp
    CS.Events.OnPetChanged()
    return true
end

--[[--
    Increases the current pet HP value on a character sheet by a given number.
    @tparam table sheet The character sheet.
    @tparam[opt=1] number number The number by which to increase the pet HP
        value.
    @treturn boolean true iff the assignment was successful, false otherwise.
    @treturn ?string A message describing why the assignment is invalid.
]]
M.increment_pet_hp = function(sheet, number)
    number = number or 1
    return M.set_pet_hp(sheet, sheet.PetHP + number)
end

--[[--
    Decreases the current pet HP value on a character sheet by a given number.
    @tparam table sheet The character sheet.
    @tparam[opt=1] number number The number by which to decrease the pet HP
        value.
    @treturn boolean true iff the assignment was successful, false otherwise.
    @treturn ?string A message describing why the assignment is invalid.
]]
M.decrement_pet_hp = function(sheet, number)
    number = number or 1
    return M.set_pet_hp(sheet, sheet.PetHP - number)
end

-- Rolls

--[[--
    Makes an attribute roll.
    @tparam table sheet The character sheet.
    @tparam string attribute The attribute's name.
    @tparam[opt=0] number modifier A modifier to add on top of the roll after
        the attribute bonus has been added.
]]
M.roll_stat = function(sheet, attribute, modifier)
    local lower = 1
    local upper = 20

    -- Natural d20 if no attribute is specified
    if not attribute then
        return CS.Mechanics.Roll.Roll(RollType.Raw, lower, upper)
    end

    -- d20 + mdifier if an attribute is specified
    modifier = (modifier or 0) + sheet.StatBlock[attribute]
    CS.Mechanics.Roll.Roll(RollType.Stat, lower, upper, modifier, attribute)
end

--[[--
    Makes a heal roll.
    @tparam table sheet The character sheet.
    @tparam boolean in_combat true if it's a combat heal roll, false if it's an
        out of combat heal roll.
]]
M.roll_heal = function(sheet, in_combat)
    local modifier = M.get_heal_modifier(sheet.StatBlock)
    local lower    = 1
    local upper    = in_combat and M.CombatHealRollDie or M.SafeHealRollDie
    CS.Mechanics.Roll.Roll(RollType.Heal, lower, upper, modifier)
end

--[[--
    Makes a pet attack roll.
    @tparam table sheet The character sheet.
]]
M.roll_pet_attack = function(sheet)
    CS.Mechanics.Roll.Roll(
        RollType.Pet,
        1,
        20,
        sheet.StatBlock[sheet.PetAttribute],
        sheet.PetAttribute,
        function(x) return math.ceil(x / 2) end
    )
end
