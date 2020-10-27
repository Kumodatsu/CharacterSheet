local addon_name, CS = ...
local M = {}

local T = CS.Locale.GetLocaleTranslations()

local Class = CS.Type.Class

M.CharacterSheet = Class {
    Stats        = CS.Stats.StatBlock.new(),
    HP           = 16,
    PetActive    = false,
    PetHP        = 8,
    PetAttribute = "CHA",

    -- Called when a stat or the power level is changed.
    OnStatsChanged = CS.Event.create_event(),
    -- Called when the current or max HP is changed.
    OnHPChanged    = CS.Event.create_event(),
    -- Called when the pet is toggled on or off.
    OnPetToggled   = CS.Event.create_event(),
    -- Called when the pet HP or pet attack attribute is changed.
    OnPetChanged   = CS.Event.create_event(),

    clamp_hp = function(self)
        local hp_max = self.Stats:get_max_hp()
        if self.HP > hpmax then
            self:set_hp(hpmax)
        end
        local pet_hp_max = self.Stats:get_pet_max_hp()
        if self.PetHP > pet_hp_max then
            self:set_pet_hp(pet_hp_max)
        end
    end,

    set_stat = function(self, name, value)
        self.Stats[name] = value
        self.OnStatsChanged()
        if name == "CON" then
            self.OnHPChanged()
        end
    end,

    roll_stat = function(self, name, mod)
        -- Roll bounds
        local lower = 1
        local upper = 20

        -- Natural d20 if no stat is specified
        if not name then
            return CS.Roll.Roll(lower, upper)
        end

        -- d20 + mdifier if a stat is specified
        mod = (mod or 0) + self.Stats[name]
        CS.Roll.Roll(lower, upper, mod, name)
    end,

    roll_heal = function(self, in_combat)
        local mod   = self.Stats:get_heal_modifier()
        local lower = 1
        local upper = in_combat and 10 or 14
        CS.Roll.Roll(lower, upper, mod)
    end,
    
    pet_attack = function(self)
        CS.Roll.Roll(
            1,
            20,
            self.Stats[self.PetAttribute],
            self.PetAttribute,
            CS.Math.half
        )
    end,

    set_pet_attribute = function(self, attribute)
        self.PetAttribute = attribute
        self.OnPetChanged()
    end,

    set_level = function(self, level)
        self.Stats.Level = level
        self.OnStatsChanged()
        self.OnHPChanged()
    end,
    
    set_hp = function(self, value)
        self.HP = value
        self.OnHPChanged()
    end,

    increment_hp = function(self, number)
        number = number or 1
        self:set_hp(self.HP + number)
    end,

    decrement_hp = function(self, number)
        number = number or 1
        self:set_hp(self.HP - number)
    end,

    toggle_pet = function(self, active)
        if active == nil then
            active = not self.PetActive
        end
        self.PetActive = active
        self.OnPetToggled(active)
    end,

    set_pet_hp = function(self, value)
        self.PetHP = value
        M.OnPetChanged()
    end,

    increment_pet_hp = function(self, number)
        number = number or 1
        self:set_pet_hp(self.PetHP + number)
    end,

    decrement_pet_hp = function(self, number)
        number = number or 1
        self:set_pet_hp(self.PetHP - number)
    end
    
}

CS.CharacterSheet = M
