local addon_name, CS = ...

-- Will be loaded from file on addon load
CS.Interface.UIState.StatsFrameVisible = true

local update_hp_bar = function(self)
    local hp     = CS.Mechanics.Sheet.HP
    local hp_max = CS.Mechanics.Sheet.Stats:get_max_hp()
    local text   = string.format("%d/%d", hp, hp_max)
    self.text:SetText(text)
    self:SetMinMaxValues(0, hp_max)
    self:SetValue(hp)
end

local update_pet_hp_bar = function(self)
    local sheet      = CS.Mechanics.Sheet
    local pet_active = sheet.PetActive
    local hp         = pet_active and sheet.PetHP or 0
    local hp_max     = pet_active and sheet.Stats:get_pet_max_hp() or 0
    local text       = string.format("%d/%d", hp, hp_max)
    self.text:SetText(text)
    self:SetMinMaxValues(0, hp_max)
    self:SetValue(hp)
end

local update_stat_button = function(stat)
    return function(self)
        local text = string.format("%s: %d", stat, CS.Mechanics.Sheet.Stats[stat])
        self:SetText(text)
    end
end

local default_height = 20 + 6 * 32 + 2 * 24

local toggle_pet_info = function()
    local visible = CS.Mechanics.Sheet.PetActive
    CS.Interface.Toggle(CS_PetHPBar_Decrement, visible)
    CS.Interface.Toggle(CS_PetHPBar, visible)
    CS.Interface.Toggle(CS_PetHPBar_Increment, visible)
    CS.Interface.Toggle(CS_PetAttackButton, visible)
    local delta = visible and (20 + 24) or 0
    CS_StatsFrame:SetHeight(default_height + delta)
end


CS.Interface.Frame {
    Global     = "CS_StatsFrame",
    Backdrop   = {
        Background = "Interface\\DialogFrame\\UI-DialogBox-Background",
        Edges      = "Interface\\DialogFrame\\UI-DialogBox-Border",
        Tiled      = true,
        TileSize   = 32,
        EdgeSize   = 32,
        Insets     = {
            Left   = 11,
            Right  = 12,
            Top    = 12,
            Bottom = 11
        }
    },
    Width      = 110,
    Height     = default_height,
    Point      = { "CENTER", UIParent, "CENTER" },
    Movable    = true,
    Clamped    = true,
    Events     = {
        [CS.OnAddonLoaded]    = {
            function(self)
                if CS.Interface.UIState.StatsFrameVisible then
                    self:Show()
                else
                    self:Hide()
                end
            end,
            toggle_pet_info
        },
        [CS.OnAddonUnloading] = {
            function(self)
                CS.Interface.UIState.StatsFrameVisible = self:IsVisible()
            end
        },
        [CS.CharacterSheet.OnPetToggled] = {
            toggle_pet_info
        }
    },
    Content    = {
        -- HP bar
        CS.Interface.Button {
            Width     = 20,
            Height    = 20,
            Texture   = "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.25, 0.5 },
            OnClick   = function(self)
                CS.Mechanics.Sheet:decrement_hp()
            end
        },
        CS.Interface.StatusBar {
            Orientation = "HORIZONTAL",
            Width       = 70,
            Height      = 20,
            Foreground = {
                Texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
                Color   = { 0.1, 0.9, 0.3, 1.0 }
            },
            Background  = {
                Texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
                Color   = { 0.0, 0.35, 0.0, 1.0 }
            },
            Events      = {
                [CS.OnAddonLoaded]              = { update_hp_bar },
                [CS.CharacterSheet.OnHPChanged] = { update_hp_bar }
            }
        },
        CS.Interface.Button {
            Width     = 20,
            Height    = 20,
            Texture   = "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.0, 0.25 },
            OnClick   = function(self)
                CS.Mechanics.Sheet:increment_hp()
            end
        },
        -- Stats
        CS.Interface.Icon {
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Beast.blp"
        },
        CS.Interface.Button {
            Width   = 110 - 32,
            Height  = 32,
            Text    = "STR",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "STR"
            end,
            Events  = {
                [CS.OnAddonLoaded]                 = { update_stat_button "STR" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat_button "STR" }
            }
        },
        CS.Interface.Icon {
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Flying.blp"
        },
        CS.Interface.Button {
            Width   = 110 - 32,
            Height  = 32,
            Text    = "DEX",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "DEX"
            end,
            Events  = {
                [CS.OnAddonLoaded]                 = { update_stat_button "DEX" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat_button "DEX" }
            }
        },
        CS.Interface.Icon {
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Humanoid.blp"
        },
        CS.Interface.Button {
            Width   = 110 - 32,
            Height  = 32,
            Text    = "CON",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "CON"
            end,
            Events  = {
                [CS.OnAddonLoaded]                 = { update_stat_button "CON" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat_button "CON" }
            }
        },
        CS.Interface.Icon {
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Mechanical.blp"
        },
        CS.Interface.Button {
            Width   = 110 - 32,
            Height  = 32,
            Text    = "INT",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "INT"
            end,
            Events  = {
                [CS.OnAddonLoaded]                 = { update_stat_button "INT" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat_button "INT" }
            }
        },
        CS.Interface.Icon {
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Dragon.blp"
        },
        CS.Interface.Button {
            Width   = 110 - 32,
            Height  = 32,
            Text    = "WIS",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "WIS"
            end,
            Events  = {
                [CS.OnAddonLoaded]                 = { update_stat_button "WIS" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat_button "WIS" }
            }
        },
        CS.Interface.Icon {
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Magical.blp"
        },
        CS.Interface.Button {
            Width   = 110 - 32,
            Height  = 32,
            Text    = "CHA",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "CHA"
            end,
            Events  = {
                [CS.OnAddonLoaded]                 = { update_stat_button "CHA" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat_button "CHA" }
            }
        },
        -- Heal button
        CS.Interface.Button {
            Width     = 110,
            Height    = 24,
            Text      = "Heal",
            Texture   = "Interface\\BUTTONS\\UI-DialogBox-Button-Gold-Up.blp",
            TexCoords = { 0.0, 1.0, 0.0, 0.6 },
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_heal()
            end
        },
        -- Pet HP bar
        CS.Interface.Button {
            Global    = "CS_PetHPBar_Decrement",
            Width     = 20,
            Height    = 20,
            Texture   = "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.25, 0.5 },
            OnClick = function(self)
                CS.Mechanics.Sheet:decrement_pet_hp()
            end
        },
        CS.Interface.StatusBar {
            Global      = "CS_PetHPBar",
            Orientation = "HORIZONTAL",
            Width       = 70,
            Height      = 20,
            Foreground = {
                Texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
                Color   = { 0.4, 0.9, 0.3, 1.0 }
            },
            Background  = {
                Texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
                Color   = { 0.0, 0.35, 0.0, 1.0 }
            },
            Events      = {
                [CS.OnAddonLoaded]                 = { update_pet_hp_bar },
                [CS.CharacterSheet.OnPetToggled]   = { update_pet_hp_bar },
                [CS.CharacterSheet.OnPetChanged]   = { update_pet_hp_bar },
                [CS.CharacterSheet.OnStatsChanged] = { update_pet_hp_bar }
            }
        },
        CS.Interface.Button {
            Global    = "CS_PetHPBar_Increment",
            Width     = 20,
            Height    = 20,
            Texture   = "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.0, 0.25 },
            OnClick = function(self)
                CS.Mechanics.Sheet:increment_pet_hp()
            end
        },
        -- Pet attack button
        CS.Interface.Button {
            Global    = "CS_PetAttackButton",
            Width     = 110,
            Height    = 24,
            Text      = "Pet Attack",
            Texture   = "Interface\\BUTTONS\\UI-DialogBox-Button-Gold-Up.blp",
            TexCoords = { 0.0, 1.0, 0.0, 0.6 },
            OnClick   = function(self)
                CS.Mechanics.Sheet:pet_attack()
            end
        }
    }
}
