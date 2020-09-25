local addon_name, CS = ...

-- Will be loaded from file on addon load
CS.Interface.UIState.EditFrameVisible = true

local update_stat = function(stat)
    return function(self)
        local text = string.format("%s: %d", stat, CS.Charsheet.Stats[stat])
        self.text:SetText(text)
    end
end

local power_menu = {
    {
        text = "Power Level",
        isTitle = true,
        notCheckable = true
    }, {
        text = "Novice",
        func = function() CS.Charsheet.set_level "Novice" end,
        checked = function() return CS.Charsheet.Stats.Level == CS.Stats.PowerLevel.Novice end
    }, {
        text = "Apprentice",
        func = function() CS.Charsheet.set_level "Apprentice" end,
        checked = function() return CS.Charsheet.Stats.Level == CS.Stats.PowerLevel.Apprentice end
    }, {
        text = "Adept",
        func = function() CS.Charsheet.set_level "Adept" end,
        checked = function() return CS.Charsheet.Stats.Level == CS.Stats.PowerLevel.Adept end
    }, {
        text = "Expert",
        func = function() CS.Charsheet.set_level "Expert" end,
        checked = function() return CS.Charsheet.Stats.Level == CS.Stats.PowerLevel.Expert end
    }, {
        text = "Master",
        func = function() CS.Charsheet.set_level "Master" end,
        checked = function() return CS.Charsheet.Stats.Level == CS.Stats.PowerLevel.Master end
    }
}

local update_power = function(self)
    self:SetText(CS.Stats.PowerLevel.to_string(CS.Charsheet.Stats.Level))
end

local update_derived = function(self)
    self.text:SetText(string.format(
        "HP: %d\nHeal mod: +%d\nSP: %d",
        CS.Charsheet.Stats:get_max_hp(),
        CS.Charsheet.Stats:get_heal_modifier(),
        CS.Charsheet.Stats:get_remaining_sp()
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
                [CS.OnAddonLoaded]            = { update_power },
                [CS.Charsheet.OnStatsChanged] = { update_power }
            }
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("STR", CS.Charsheet.Stats.STR - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = "STR",
            Events = {
                [CS.OnAddonLoaded]            = { update_stat "STR" },
                [CS.Charsheet.OnStatsChanged] = { update_stat "STR" }
            }
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("STR", CS.Charsheet.Stats.STR + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("DEX", CS.Charsheet.Stats.DEX - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = "DEX",
            Events = {
                [CS.OnAddonLoaded]            = { update_stat "DEX" },
                [CS.Charsheet.OnStatsChanged] = { update_stat "DEX" }
            }
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("DEX", CS.Charsheet.Stats.DEX + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("CON", CS.Charsheet.Stats.CON - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = "CON",
            Events = {
                [CS.OnAddonLoaded]            = { update_stat "CON" },
                [CS.Charsheet.OnStatsChanged] = { update_stat "CON" }
            }
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("CON", CS.Charsheet.Stats.CON + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("INT", CS.Charsheet.Stats.INT - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = "INT",
            Events = {
                [CS.OnAddonLoaded]            = { update_stat "INT" },
                [CS.Charsheet.OnStatsChanged] = { update_stat "INT" }
            }
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("INT", CS.Charsheet.Stats.INT + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("WIS", CS.Charsheet.Stats.WIS - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = "WIS",
            Events = {
                [CS.OnAddonLoaded]            = { update_stat "WIS" },
                [CS.Charsheet.OnStatsChanged] = { update_stat "WIS" }
            }
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("WIS", CS.Charsheet.Stats.WIS + 1)
            end
        },

        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("CHA", CS.Charsheet.Stats.CHA - 1)
            end
        },
        CS.Interface.Text {
            Width  = 180 - 2 * 32,
            Height = 32,
            Text   = "CHA",
            Events = {
                [CS.OnAddonLoaded]            = { update_stat "CHA" },
                [CS.Charsheet.OnStatsChanged] = { update_stat "CHA" }
            }
        },
        CS.Interface.Button {
            Width     = 32,
            Height    = 32,
            Texture   = "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp",
            OnClick   = function()
                CS.Charsheet.set_stat("CHA", CS.Charsheet.Stats.CHA + 1)
            end
        },

        CS.Interface.Text {
            Width  = 180,
            Height = 48,
            Events = {
                [CS.OnAddonLoaded]            = { update_derived },
                [CS.Charsheet.OnStatsChanged] = { update_derived }
            }
        }
    }
}
