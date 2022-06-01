--[[
    The interface code is going to need some major refactoring.
    Just looking at the hacky stuff going on in this file makes me nauseous.
]]

local addon_name, CS = ...

local T = CS.Locale.GetLocaleTranslations()

-- Will be loaded from file on addon load
CS.Interface.UIState.StatsFrameVisible = false

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
        local text = string.format(
            "%s: %d",
            stat,
            CS.Mechanics.Sheet.Stats[stat]
        )
        self:SetText(text)
    end
end

local default_height = 20 + 6 * 32 + 2 * 24

local get_required_height = function()
    local height = default_height
    local elems  = { CS_ResourceBar, CS_PetHPBar, CS_PetAttackButton }
    for _, elem in ipairs(elems) do
        if elem:IsVisible() then
            height = height + elem:GetHeight()
        end
    end
    return height
end

local toggle_pet_info = function()
    local visible = CS.Mechanics.Sheet.PetActive
    CS.Interface.Toggle(CS_PetHPBar_Decrement, visible)
    CS.Interface.Toggle(CS_PetHPBar, visible)
    CS.Interface.Toggle(CS_PetHPBar_Increment, visible)
    CS.Interface.Toggle(CS_PetAttackButton, visible)
    CS_StatsFrame:SetHeight(get_required_height())
end

local elem_offsets = nil

local init_offsets = function()
    local elems = {
        CS_CombatButton,
        CS_HealButton,
        CS_PetHPBar_Decrement,
        CS_PetHPBar,
        CS_PetHPBar_Increment,
        CS_PetAttackButton
    }
    for _, stat in ipairs { "STR", "DEX", "CON", "INT", "WIS", "CHA" } do
        table.insert(elems, _G["CS_StatIcon_"   .. stat])
        table.insert(elems, _G["CS_StatButton_" .. stat])
    end

    if elem_offsets then return elems end

    elem_offsets = {}
    for _, elem in ipairs(elems) do
        local _, _, _, x, y = elem:GetPoint(1)
        elem_offsets[elem]  = { x = x, y = y }
    end

    return elems
end

local update_resource = function(self)
    local resource = CS.Mechanics.Sheet.Resource
    local visible  = resource ~= nil
    local elems    = {
        CS_ResourceBar_Decrement,
        CS_ResourceBar,
        CS_ResourceBar_Increment
    }
    for _, elem in ipairs(elems) do
        CS.Interface.Toggle(elem, visible)
    end
    CS_StatsFrame:SetHeight(get_required_height())
    
    elems = init_offsets()

    local offset = visible and 0 or 20

    for _, elem in ipairs(elems) do
        elem:SetPoint(
            "TOPLEFT",
            CS_StatsFrame,
            "TOPLEFT",
            elem_offsets[elem].x,
            elem_offsets[elem].y + offset
        )
    end

    if not resource then return end
    
    local color = resource.Color or { 1.0, 1.0, 1.0, 1.0 }
    local text_color = resource.TextColor or { 1.0, 1.0, 1.0, 1.0 }
    CS_ResourceBar:SetStatusBarColor(color[1], color[2], color[3], color[4])
    CS_ResourceBar.background:SetVertexColor(0.2 * color[1], 0.2 * color[2],
        0.2 * color[3], 1.0)
    CS_ResourceBar.text:SetTextColor(text_color[1], text_color[2],
        text_color[3], text_color[4])
    
    local v     = resource.Value
    local v_max = resource.Max
    local text  = string.format("%d/%d", v, v_max)
    self.text:SetText(text)
    self:SetMinMaxValues(0, v_max)
    self:SetValue(v)
end

local in_combat = false

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
    Point      = { "CENTER", UIParent, "CENTER", -145, 0 },
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
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.25, 0.5 },
            OnClick   = function(self)
                CS.Mechanics.Sheet:decrement_hp()
            end
        },
        CS.Interface.StatusBar {
            Orientation = "HORIZONTAL",
            Width       = 70,
            Height      = 20,
            TextColor   = { 0.0, 1.0, 0.0, 1.0 },
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
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.0, 0.25 },
            OnClick   = function(self)
                CS.Mechanics.Sheet:increment_hp()
            end
        },
        -- Resource bar
        CS.Interface.Button {
            Global    = "CS_ResourceBar_Decrement",
            Width     = 20,
            Height    = 20,
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.25, 0.5 },
            OnClick   = function(self)
                CS.Mechanics.Sheet:decrement_resource()
            end
        },
        CS.Interface.StatusBar {
            Global      = "CS_ResourceBar",
            Orientation = "HORIZONTAL",
            Width       = 70,
            Height      = 20,
            Foreground = {
                Texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
                Color   = { 0.1, 0.3, 0.9, 1.0 }
            },
            Background  = {
                Texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
                Color   = { 0.0, 0.0, 0.35, 1.0 }
            },
            Events      = {
                [CS.OnAddonLoaded]                    = { update_resource },
                [CS.CharacterSheet.OnResourceChanged] = { update_resource }
            }
        },
        CS.Interface.Button {
            Global    = "CS_ResourceBar_Increment",
            Width     = 20,
            Height    = 20,
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.0, 0.25 },
            OnClick   = function(self)
                CS.Mechanics.Sheet:increment_resource()
            end
        },
        -- Stats
        CS.Interface.Icon {
            Global  = "CS_StatIcon_STR",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Beast.blp"
        },
        CS.Interface.Button {
            Global  = "CS_StatButton_STR",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "STR",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "STR"
            end,
            Events  = {
                [CS.OnAddonLoaded] = {
                    update_stat_button "STR"
                },
                [CS.CharacterSheet.OnStatsChanged] = {
                    update_stat_button "STR"
                }
            }
        },
        CS.Interface.Icon {
            Global  = "CS_StatIcon_DEX",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Flying.blp"
        },
        CS.Interface.Button {
            Global  = "CS_StatButton_DEX",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "DEX",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "DEX"
            end,
            Events  = {
                [CS.OnAddonLoaded] = {
                    update_stat_button "DEX"
                },
                [CS.CharacterSheet.OnStatsChanged] = {
                    update_stat_button "DEX"
                }
            }
        },
        CS.Interface.Icon {
            Global  = "CS_StatIcon_CON",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Humanoid.blp"
        },
        CS.Interface.Button {
            Global  = "CS_StatButton_CON",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "CON",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "CON"
            end,
            Events  = {
                [CS.OnAddonLoaded] = {
                    update_stat_button "CON"
                },
                [CS.CharacterSheet.OnStatsChanged] = {
                    update_stat_button "CON"
                }
            }
        },
        CS.Interface.Icon {
            Global  = "CS_StatIcon_INT",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Mechanical.blp"
        },
        CS.Interface.Button {
            Global  = "CS_StatButton_INT",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "INT",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "INT"
            end,
            Events  = {
                [CS.OnAddonLoaded] = {
                    update_stat_button "INT"
                },
                [CS.CharacterSheet.OnStatsChanged] = {
                    update_stat_button "INT"
                }
            }
        },
        CS.Interface.Icon {
            Global  = "CS_StatIcon_WIS",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Dragon.blp"
        },
        CS.Interface.Button {
            Global  = "CS_StatButton_WIS",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "WIS",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "WIS"
            end,
            Events  = {
                [CS.OnAddonLoaded] = {
                    update_stat_button "WIS"
                },
                [CS.CharacterSheet.OnStatsChanged] = {
                    update_stat_button "WIS"
                }
            }
        },
        CS.Interface.Icon {
            Global  = "CS_StatIcon_CHA",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Magical.blp"
        },
        CS.Interface.Button {
            Global  = "CS_StatButton_CHA",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "CHA",
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_stat "CHA"
            end,
            Events  = {
                [CS.OnAddonLoaded] = {
                    update_stat_button "CHA"
                },
                [CS.CharacterSheet.OnStatsChanged] = {
                    update_stat_button "CHA"
                }
            }
        },
        -- Heal button
        CS.Interface.Checkbox {
            Global  = "CS_CombatButton",
            Width    = 24,
            Height   = 24,
            Enabled  = {
                Texture = "Interface\\ICONS\\PetJournalPortrait.blp"
            },
            Disabled = {
                Texture = "Interface\\ICONS\\Spell_Misc_PetHeal.blp"
            },
            OnClick = function(self)
                in_combat = not in_combat
                CS_HealButton:SetText(
                  in_combat and T.COMBAT_HEAL or T.SAFE_HEAL
                )
            end
        },
        CS.Interface.Button {
            Global    = "CS_HealButton",
            Width     = 110 - 24,
            Height    = 24,
            Text      = in_combat and T.COMBAT_HEAL or T.SAFE_HEAL,
            Texture   = "Interface\\BUTTONS\\UI-DialogBox-Button-Gold-Up.blp",
            TexCoords = { 0.0, 1.0, 0.0, 0.6 },
            OnClick = function(self)
                CS.Mechanics.Sheet:roll_heal(in_combat)
            end
        },
        -- Pet HP bar
        CS.Interface.Button {
            Global    = "CS_PetHPBar_Decrement",
            Width     = 20,
            Height    = 20,
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
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
            TextColor   = { 0.0, 1.0, 0.0, 1.0 },
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
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
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
