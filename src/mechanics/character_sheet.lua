local addon_name, CS = ...
local M = {}

local T = CS.Locale.GetLocaleTranslations()

local Class    = CS.Type.Class
local Roll     = CS.Roll.Roll
local RollType = CS.Roll.RollType

M.SafeHealRollDie   = 14
M.CombatHealRollDie = 10
M.KnockOutValue     = -5

-- Called when a stat or the power level is changed.
M.OnStatsChanged    = CS.Event.create_event()
-- Called when the current or max HP is changed.
M.OnHPChanged       = CS.Event.create_event()
-- Called when the pet is toggled on or off.
M.OnPetToggled      = CS.Event.create_event()
-- Called when the pet HP or pet attack attribute is changed.
M.OnPetChanged      = CS.Event.create_event()
-- Called when a resource is added, removed or changed.
M.OnResourceChanged = CS.Event.create_event()

M.CharacterSheet = Class {
    Stats        = CS.Stats.StatBlock.new(),
    HP           = 16,
    PetActive    = false,
    PetHP        = 8,
    PetAttribute = "CHA",
    Resources    = {},

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
        if value < CS.Stats.StatMinVal or value > CS.Stats.StatMaxVal then
            return false, T.MSG_RANGE(CS.Stats.StatMinVal, CS.Stats.StatMaxVal)
        end
        local old_value = self.Stats[name]
        self.Stats[name] = value
        local valid, msg = self.Stats:validate()
        if not valid then
            self.Stats[name] = old_value
            return false, msg
        end
        M.OnStatsChanged()
        if name == "CON" then
            M.OnHPChanged()
        end
        return true
    end,

    roll_stat = function(self, name, mod)
        -- Roll bounds
        local lower = 1
        local upper = 20

        -- Natural d20 if no stat is specified
        if not name then
            return Roll(RollType.Raw, lower, upper)
        end

        -- d20 + mdifier if a stat is specified
        mod = (mod or 0) + self.Stats[name]
        Roll(RollType.Stat, lower, upper, mod, name)
    end,

    roll_heal = function(self, in_combat)
        local mod   = self.Stats:get_heal_modifier()
        local lower = 1
        local upper = in_combat and M.CombatHealRollDie or M.SafeHealRollDie
        Roll(RollType.Heal, lower, upper, mod)
    end,
    
    pet_attack = function(self)
        Roll(
            RollType.Pet,
            1,
            20,
            self.Stats[self.PetAttribute],
            self.PetAttribute,
            CS.Math.half
        )
    end,

    set_pet_attribute = function(self, attribute)
        self.PetAttribute = attribute
        M.OnPetChanged()
        return true
    end,

    set_level = function(self, level)
        self.Stats.Level = level
        -- If the change in level causes one to have fewer SP than they have spent,
        -- reduce stats until the number of SP spent is valid again
        local sp = self.Stats:get_remaining_sp()
        for _, attribute in ipairs(CS.Stats.AttributeNames) do
            while self.Stats[attribute] > CS.Stats.StatMinVal and sp < 0 do 
                self.Stats[attribute] = self.Stats[attribute] - 1
                sp = sp + 1
            end
        end
        M.OnStatsChanged()
        M.OnHPChanged()
        return true
    end,
    
    set_hp = function(self, value)
        if value < M.KnockOutValue or value > self.Stats:get_max_hp() then
            return false, T.MSG_SET_HP_ALLOWED_VALUES
        end
        self.HP = value
        M.OnHPChanged()
        return true
    end,

    increment_hp = function(self, number)
        number = number or 1
        return self:set_hp(self.HP + number)
    end,

    decrement_hp = function(self, number)
        number = number or 1
        return self:set_hp(self.HP - number)
    end,

    toggle_pet = function(self, active)
        if active == nil then
            active = not self.PetActive
        end
        self.PetActive = active
        M.OnPetToggled(active)
    end,

    set_pet_hp = function(self, value)
        if value < M.KnockOutValue or value > self.Stats:get_pet_max_hp() then
            return false, T.MSG_SET_PET_HP_ALLOWED_VALUES
        end
        self.PetHP = value
        M.OnPetChanged()
        return true
    end,

    increment_pet_hp = function(self, number)
        number = number or 1
        return self:set_pet_hp(self.PetHP + number)
    end,

    decrement_pet_hp = function(self, number)
        number = number or 1
        return self:set_pet_hp(self.PetHP - number)
    end,

    add_resource = function(self, resource)
        if self.Resources[resource.Name] then
            return false, T.MSG_DUPLICATE_RESOURCE(resource.Name)
        end
        self.Resources[resource.Name] = resource
        M.OnResourceChanged(resource.Name)
        return true
    end,

    remove_resource = function(self, resource_name)
        if not self.Resources[resource_name] then
            return false, T.MSG_RESOURCE_DOESNT_EXIST(resource_name)
        end
        self.Resources[resource_name] = nil
        M.OnResourceChanged(resource_name)
        return true
    end,
    
    set_resource = function(self, resource_name, value)
        local resource = self.Resources[resource_name] 
        if not resource then
            return false, T.MSG_RESOURCE_DOESNT_EXIST(resource_name)
        end
        local min = resource:get_min()
        local max = resource:get_max()
        if value < min or value > max then
            return false, T.MSG_RESOURCE_ALLOWED_VALUES(resource_name, min, max)
        end
        resource.Value = value
        M.OnResourceChanged(resource_name)
        return true
    end,

    increment_resource = function(self, resource_name, number)
        number = number or 1
        local resource = self.Resources[resource_name]
        return self:set_resource(
            resource_name,
            resource and resource.Value + number or 0
        )
    end,

    decrement_resource = function(self, resource_name, number)
        number = number or 1
        return self:increment_resource(resource_name, -number)
    end

}

CS.CharacterSheet = M
