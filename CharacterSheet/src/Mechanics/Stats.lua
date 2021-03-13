local addon_name, CS = ...
CS.Mechanics = CS.Mechanics or {}
CS.Mechanics.Stats = {}

local M = CS.Mechanics.Stats

local T = CS.Locale.GetLocaleTranslations()

local RollType = CS.Mechanics.Roll.RollType

M.StatMinValue      =  5
M.StatMaxValue      = 24
M.SafeHealRollDie   = 14
M.CombatHealRollDie = 10
M.KnockOutValue     = -5

-- Called when a stat or the power level is changed.
CS.Events.OnStatsChanged    = CS.Event.create_event()
-- Called when the current or max HP is changed.
CS.Events.OnHPChanged       = CS.Event.create_event()
-- Called when the pet is toggled on or off.
CS.Events.OnPetToggled      = CS.Event.create_event()
-- Called when the pet HP or pet attack attribute is changed.
CS.Events.OnPetChanged      = CS.Event.create_event()
-- Called when a resource is added, removed or changed.
CS.Events.OnResourceChanged = CS.Event.create_event()

M.AttributeNames = { "STR", "DEX", "CON", "INT", "WIS", "CHA" }

M.PowerLevel = {
    Novice     = 1,
    Apprentice = 2,
    Adept      = 3,
    Expert     = 4,
    Master     = 5
}

M.is_valid_attribute = function(name)
    for _, attrib in ipairs(M.AttributeNames) do
        if attrib == name then return true end
    end
    return false
end

M.power_level_name = function(level)
    return ({
        "Novice", "Apprentice", "Adept", "Expert", "Master"
    })[level]
end

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

M.get_sp_bonus = function(level)
    return 14 + 2 * level
end

M.get_hp_bonus = function(level)
    return 2 * level
end

M.create_stat_block = function(level, str, dex, con, int, wis, cha)
    local stat_block = {
        STR   = str   or 13,
        DEX   = dex   or 13,
        CON   = con   or 13,
        INT   = int   or 13,
        WIS   = wis   or 13,
        CHA   = cha   or 13,
        Level = level or M.PowerLevel.Apprentice
    }
    local valid, msg = M.validate(stat_block)
    if not valid then
        return false, msg
    end
    return true, stat_block
end

M.get_attributes = function(stat_block)
    local index = 1
    return function()
        local attribute_name = M.AttributeNames[index]
        local value          = stat_block[attribute_name]
        index = index + 1
        return attribute_name, value
    end
end

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

M.get_max_hp = function(stat_block)
    return stat_block.CON + M.get_hp_bonus(stat_block.Level)
end

M.get_pet_max_hp = function(stat_block)
    return math.ceil(M.get_max_hp(stat_block) / 2)
end

M.get_potential_sp = function(stat_block)
    return 60 + M.get_sp_bonus(stat_block.Level)
end

M.get_total_sp = function(stat_block)
    local total = 0
    for _, value in M.get_attributes(stat_block) do
        total = total + value
    end
    return total
end

M.get_remaining_sp = function(stat_block)
    return M.get_potential_sp(stat_block) - M.get_total_sp(stat_block)
end

M.get_heal_modifier = function(stat_block)
    return math.floor(math.max(0, stat_block.CHA - 10) / 2)
end

M.create_character_sheet = function(stat_block, pet_active, pet_attribute,
        hp, pet_hp)
    if not stat_block then
        local valid, error_or_value = M.create_stat_block()
        if not valid then
            return false, error_or_value
        end
        stat_block = error_or_value
    end
    local sheet = {
        StatBlock    = stat_block,
        PetActive    = pet_active    or false,
        PetAttribute = pet_attribtue or "CHA"
    }
    sheet.HP    = hp     or M.get_max_hp(sheet.StatBlock)
    sheet.PetHP = pet_hp or M.get_pet_max_hp(sheet.StatBlock)
    return true, sheet
end

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

M.set_pet_attribute = function(sheet, attribute)
    sheet.PetAttribute = attribute
    CS.Events.OnPetChanged()
    return true
end

M.toggle_pet = function(sheet, active)
    if active == nil then
        active = not sheet.PetActive
    end
    sheet.PetActive = active
    CS.Events.OnPetToggled(active)
end

M.set_level = function(sheet, level)
    sheet.StatBlock.Level = level
    -- If the change in level causes one to have fewer SP than they have spent,
    -- reduce stats until the number of SP spent is valid again
    local sp = M.get_remaining_sp(sheet.StatBlock)
    for _, attribute in ipairs(M.AttributeNames) do
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

M.set_hp = function(sheet, hp)
    if hp < M.KnockOutValue or hp > M.get_max_hp(sheet.StatBlock) then
        return false, T.MSG_SET_HP_ALLOWED_VALUES
    end
    sheet.HP = hp
    CS.Events.OnHPChanged()
    return true
end

M.increment_hp = function(sheet, number)
    number = number or 1
    return M.set_hp(sheet, sheet.HP + number)
end

M.decrement_hp = function(sheet, number)
    number = number or 1
    return M.set_hp(sheet, sheet.HP - number)
end

M.set_pet_hp = function(sheet, hp)
    if hp < M.KnockOutValue or hp > M.get_pet_max_hp(sheet.StatBlock) then
        return false, T.MSG_SET_PET_HP_ALLOWED_VALUES
    end
    sheet.PetHP = hp
    CS.Events.OnPetChanged()
    return true
end

M.increment_pet_hp = function(sheet, number)
    number = number or 1
    return M.set_pet_hp(sheet, sheet.PetHP + number)
end

M.decrement_pet_hp = function(sheet, number)
    number = number or 1
    return M.set_pet_hp(sheet, sheet.PetHP - number)
end

-- Rolls

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

M.roll_heal = function(sheet, in_combat)
    local modifier = M.get_heal_modifier(sheet.StatBlock)
    local lower    = 1
    local upper    = in_combat and M.CombatHealRollDie or M.SafeHealRollDie
    CS.Mechanics.Roll.Roll(RollType.Heal, lower, upper, modifier)
end

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
