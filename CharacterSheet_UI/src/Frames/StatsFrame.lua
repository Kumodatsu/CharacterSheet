local addon_name, CS_UI = ...

local stats_frame_visible = false
local in_combat           = false

local default_height = 20 + 6 * 32 + 24

local E         = CS_API.Events
local S         = CS_API.Mechanics.Stats
local get_sheet = CS_API.State.Sheet.get_character_sheet
local I         = CS_UI.Interface

local update_hp_bar = function(self)
    local sheet  = get_sheet()
    local hp     = sheet.HP
    local hp_max = S.get_max_hp(sheet.StatBlock)
    local text   = string.format("%d/%d", hp, hp_max)
    self.text:SetText(text)
    self:SetMinMaxValues(0, hp_max)
    self:SetValue(hp)
end

local update_stat_button = function(attribute)
    return function(self)
        local sheet = get_sheet()
        local text = string.format(
            "%s: %d",
            attribute,
            sheet.StatBlock[attribute]
        )
        self:SetText(text)
    end
end

I.Frame {
    Global     = "CS_UI_StatsFrame",
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
        [E.AfterAddonLoaded]    = {
            function(self)
                if stats_frame_visible then
                    self:Show()
                else
                    self:Hide()
                end
            end --[[,
            toggle_pet_info ]]
        },
        [E.OnAddonUnloading] = {
            function(self)
                stats_frame_visible = self:IsVisible()
            end
        } --[[,
        [E.OnPetToggled] = {
            toggle_pet_info
        } ]]
    },
    Content    = {
        -- HP bar
        I.Button {
            Width     = 20,
            Height    = 20,
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.25, 0.5 },
            OnClick   = function(self)
                local sheet = get_sheet()
                S.decrement_hp(sheet)
            end
        },
        I.StatusBar {
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
                [E.AfterAddonLoaded]              = { update_hp_bar },
                [E.OnHPChanged] = { update_hp_bar }
            }
        },
        I.Button {
            Width     = 20,
            Height    = 20,
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.0, 0.25 },
            OnClick   = function(self)
                local sheet = get_sheet()
                S.increment_hp(sheet)
            end
        },
        --[[ Resource bar
        I.Button {
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
        I.StatusBar {
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
                [E.AfterAddonLoaded]                    = { update_resource },
                [E.OnResourceChanged] = { update_resource }
            }
        },
        I.Button {
            Global    = "CS_ResourceBar_Increment",
            Width     = 20,
            Height    = 20,
            Texture   =
                "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.0, 0.25 },
            OnClick   = function(self)
                CS.Mechanics.Sheet:increment_resource()
            end
        }, ]]
        -- Stats
        I.Icon {
            Global  = "CS_StatIcon_STR",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Beast.blp"
        },
        I.Button {
            Global  = "CS_StatButton_STR",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "STR",
            OnClick = function(self)
                S.roll_stat(get_sheet(), "STR")
            end,
            Events  = {
                [E.AfterAddonLoaded] = {
                    update_stat_button "STR"
                },
                [E.OnStatsChanged] = {
                    update_stat_button "STR"
                }
            }
        },
        I.Icon {
            Global  = "CS_StatIcon_DEX",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Flying.blp"
        },
        I.Button {
            Global  = "CS_StatButton_DEX",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "DEX",
            OnClick = function(self)
                S.roll_stat(get_sheet(), "DEX")
            end,
            Events  = {
                [E.AfterAddonLoaded] = {
                    update_stat_button "DEX"
                },
                [E.OnStatsChanged] = {
                    update_stat_button "DEX"
                }
            }
        },
        I.Icon {
            Global  = "CS_StatIcon_CON",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Humanoid.blp"
        },
        I.Button {
            Global  = "CS_StatButton_CON",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "CON",
            OnClick = function(self)
                S.roll_stat(get_sheet(), "CON")
            end,
            Events  = {
                [E.AfterAddonLoaded] = {
                    update_stat_button "CON"
                },
                [E.OnStatsChanged] = {
                    update_stat_button "CON"
                }
            }
        },
        I.Icon {
            Global  = "CS_StatIcon_INT",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Mechanical.blp"
        },
        I.Button {
            Global  = "CS_StatButton_INT",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "INT",
            OnClick = function(self)
                S.roll_stat(get_sheet(), "INT")
            end,
            Events  = {
                [E.AfterAddonLoaded] = {
                    update_stat_button "INT"
                },
                [E.OnStatsChanged] = {
                    update_stat_button "INT"
                }
            }
        },
        I.Icon {
            Global  = "CS_StatIcon_WIS",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Dragon.blp"
        },
        I.Button {
            Global  = "CS_StatButton_WIS",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "WIS",
            OnClick = function(self)
                S.roll_stat(get_sheet(), "WIS")
            end,
            Events  = {
                [E.AfterAddonLoaded] = {
                    update_stat_button "WIS"
                },
                [E.OnStatsChanged] = {
                    update_stat_button "WIS"
                }
            }
        },
        I.Icon {
            Global  = "CS_StatIcon_CHA",
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Magical.blp"
        },
        I.Button {
            Global  = "CS_StatButton_CHA",
            Width   = 110 - 32,
            Height  = 32,
            Text    = "CHA",
            OnClick = function(self)
                S.roll_stat(get_sheet(), "CHA")
            end,
            Events  = {
                [E.AfterAddonLoaded] = {
                    update_stat_button "CHA"
                },
                [E.OnStatsChanged] = {
                    update_stat_button "CHA"
                }
            }
        },
        -- Heal button
        I.Checkbox {
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
            end
        },
        I.Button {
            Global    = "CS_HealButton",
            Width     = 110 - 24,
            Height    = 24,
            Text      = "Heal",
            Texture   = "Interface\\BUTTONS\\UI-DialogBox-Button-Gold-Up.blp",
            TexCoords = { 0.0, 1.0, 0.0, 0.6 },
            OnClick = function(self)
                local sheet = get_sheet()
                S.roll_heal(sheet, in_combat)
            end
        } --[[,
        -- Pet HP bar
        I.Button {
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
        I.StatusBar {
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
                [E.AfterAddonLoaded]                 = { update_pet_hp_bar },
                [E.OnPetToggled]   = { update_pet_hp_bar },
                [E.OnPetChanged]   = { update_pet_hp_bar },
                [E.OnStatsChanged] = { update_pet_hp_bar }
            }
        },
        I.Button {
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
        I.Button {
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
        ]]
    }
}
