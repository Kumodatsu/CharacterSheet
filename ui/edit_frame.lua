local addon_name, CS = ...

local T = CS.Locale.GetLocaleTranslations()

-- Will be loaded from file on addon load
CS.Interface.UIState.EditFrameVisible = true

local update_stat = function(stat)
    return function(self)
        local text = string.format("%s: %d", stat, CS.Mechanics.Sheet.Stats[stat])
        self.text:SetText(text)
    end
end

local power_menu = {
    {
        text = T.POWER_LEVEL,
        isTitle = true,
        notCheckable = true
    }, {
        text = T.NOVICE,
        func = function() CS.Mechanics.Sheet:set_level(1) end,
        checked = function() return CS.Mechanics.Sheet.Stats.Level == CS.Stats.PowerLevel.Novice end
    }, {
        text = T.APPRENTICE,
        func = function() CS.Mechanics.Sheet:set_level(2) end,
        checked = function() return CS.Mechanics.Sheet.Stats.Level == CS.Stats.PowerLevel.Apprentice end
    }, {
        text = T.ADEPT,
        func = function() CS.Mechanics.Sheet:set_level(3) end,
        checked = function() return CS.Mechanics.Sheet.Stats.Level == CS.Stats.PowerLevel.Adept end
    }, {
        text = T.EXPERT,
        func = function() CS.Mechanics.Sheet:set_level(4) end,
        checked = function() return CS.Mechanics.Sheet.Stats.Level == CS.Stats.PowerLevel.Expert end
    }, {
        text = T.MASTER,
        func = function() CS.Mechanics.Sheet:set_level(5) end,
        checked = function() return CS.Mechanics.Sheet.Stats.Level == CS.Stats.PowerLevel.Master end
    }
}

local update_power = function(self)
    self:SetText(CS.Stats.PowerLevel.to_string(CS.Mechanics.Sheet.Stats.Level))
end

local update_derived = function(self)
    self.text:SetText(T.DERIVED_STATS(
        CS.Mechanics.Sheet.Stats:get_max_hp(),
        CS.Mechanics.Sheet.Stats:get_heal_modifier(),
        CS.Mechanics.Sheet.Stats:get_remaining_sp()
    ))
end

CS.Interface.Frame {
    Global   = "CS_EditFrame",
    Backdrop = {
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
    Width    = 180,
    Height   = 32 + 6 * 32 + 48,
    Point    = { "CENTER", UIParent, "CENTER" },
    Movable  = true,
    Clamped  = true,
    Events   = {
        [CS.OnAddonLoaded]    = { function(self)
            if CS.Interface.UIState.EditFrameVisible then
                self:Show()
            else
                self:Hide()
            end
        end },
        [CS.OnAddonUnloading] = { function(self)
            CS.Interface.UIState.EditFrameVisible = self:IsVisible()
        end }
    },
    Content  = {
        CS.Interface.Dropdown {
            Global = "CS_Power",
            Width  = 180,
            Height = 32,
            Menu   = power_menu,
            Events = {
                [CS.OnAddonLoaded]                 = { update_power },
                [CS.CharacterSheet.OnStatsChanged] = { update_power }
            },
            Tooltip = T.DESC_POWER_LEVEL
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("STR", CS.Mechanics.Sheet.Stats.STR - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = T.STR,
            Events = {
                [CS.OnAddonLoaded]                 = { update_stat "STR" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat "STR" }
            },
            Tooltip = T.DESC_STR
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("STR", CS.Mechanics.Sheet.Stats.STR + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("DEX", CS.Mechanics.Sheet.Stats.DEX - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = T.DEX,
            Events = {
                [CS.OnAddonLoaded]                 = { update_stat "DEX" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat "DEX" }
            },
            Tooltip = T.DESC_DEX
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("DEX", CS.Mechanics.Sheet.Stats.DEX + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("CON", CS.Mechanics.Sheet.Stats.CON - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = T.CON,
            Events = {
                [CS.OnAddonLoaded]                 = { update_stat "CON" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat "CON" }
            },
            Tooltip = T.DESC_CON
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("CON", CS.Mechanics.Sheet.Stats.CON + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("INT", CS.Mechanics.Sheet.Stats.INT - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = T.INT,
            Events = {
                [CS.OnAddonLoaded]                 = { update_stat "INT" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat "INT" }
            },
            Tooltip = T.DESC_INT
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("INT", CS.Mechanics.Sheet.Stats.INT + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("WIS", CS.Mechanics.Sheet.Stats.WIS - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = T.WIS,
            Events = {
                [CS.OnAddonLoaded]                 = { update_stat "WIS" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat "WIS" }
            },
            Tooltip = T.DESC_WIS
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("WIS", CS.Mechanics.Sheet.Stats.WIS + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("CHA", CS.Mechanics.Sheet.Stats.CHA - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = T.CHA,
            Events = {
                [CS.OnAddonLoaded]                 = { update_stat "CHA" },
                [CS.CharacterSheet.OnStatsChanged] = { update_stat "CHA" }
            },
            Tooltip = T.DESC_CHA
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Mechanics.Sheet:set_stat("CHA", CS.Mechanics.Sheet.Stats.CHA + 1)
            end
        },

        CS.Interface.Text {
            Width  = 180,
            Height = 48,
            Events = {
                [CS.OnAddonLoaded]                 = { update_derived },
                [CS.CharacterSheet.OnStatsChanged] = { update_derived }
            }
        }
    }
}
