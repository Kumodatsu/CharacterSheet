local addon_name, CS = ...

-- Will be loaded from file on addon load
CS.Interface.UIState.StatsFrameVisible = true

local update_hp_bar = function(self)
    local hp     = CS.Charsheet.CurrentHP
    local hp_max = CS.Charsheet.Stats:get_max_hp()
    local text   = string.format("%d/%d", hp, hp_max)
    self.text:SetText(text)
    self:SetMinMaxValues(0, hp_max)
    self:SetValue(hp)
end

local update_stat_button = function(stat)
    return function(self)
        local text = string.format("%s: %d", stat, CS.Charsheet.Stats[stat])
        self:SetText(text)
    end
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
    Height     = 20 + 6 * 32,
    Point      = { "CENTER", UIParent, "CENTER" },
    Movable    = true,
    Clamped    = true,
    Events     = {
        [CS.OnAddonLoaded]    = { function(self)
            if CS.Interface.UIState.StatsFrameVisible then
                self:Show()
            else
                self:Hide()
            end
        end },
        [CS.OnAddonUnloading] = { function(self)
            CS.Interface.UIState.StatsFrameVisible = self:IsVisible()
        end }
    },
    Content    = {
        CS.Interface.Button {
            Width     = 20,
            Height    = 20,
            Texture   = "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.25, 0.5 },
            OnClick   = CS.Charsheet.decrement_hp
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
                [CS.OnAddonLoaded]         = { update_hp_bar },
                [CS.Charsheet.OnHPChanged] = { update_hp_bar }
            }
        },
        CS.Interface.Button {
            Width     = 20,
            Height    = 20,
            Texture   = "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP",
            TexCoords = { 0.0, 0.5, 0.0, 0.25 },
            OnClick   = CS.Charsheet.increment_hp
        },
        CS.Interface.Icon {
            Width   = 32,
            Height  = 32,
            Texture = "Interface\\ICONS\\Pet_Type_Beast.blp"
        },
        CS.Interface.Button {
            Width   = 110 - 32,
            Height  = 32,
            Text    = "STR",
            OnClick = CS.fwd(CS.Charsheet.roll_stat, "STR"),
            Events  = {
                [CS.OnAddonLoaded]            = { update_stat_button "STR" },
                [CS.Charsheet.OnStatsChanged] = { update_stat_button "STR" }
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
            OnClick = CS.fwd(CS.Charsheet.roll_stat, "DEX"),
            Events  = {
                [CS.OnAddonLoaded]            = { update_stat_button "DEX" },
                [CS.Charsheet.OnStatsChanged] = { update_stat_button "DEX" }
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
            OnClick = CS.fwd(CS.Charsheet.roll_stat, "CON"),
            Events  = {
                [CS.OnAddonLoaded]            = { update_stat_button "CON" },
                [CS.Charsheet.OnStatsChanged] = { update_stat_button "CON" }
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
            OnClick = CS.fwd(CS.Charsheet.roll_stat, "INT"),
            Events  = {
                [CS.OnAddonLoaded]            = { update_stat_button "INT" },
                [CS.Charsheet.OnStatsChanged] = { update_stat_button "INT" }
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
            OnClick = CS.fwd(CS.Charsheet.roll_stat, "WIS"),
            Events  = {
                [CS.OnAddonLoaded]            = { update_stat_button "WIS" },
                [CS.Charsheet.OnStatsChanged] = { update_stat_button "WIS" }
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
            OnClick = CS.fwd(CS.Charsheet.roll_stat, "CHA"),
            Events  = {
                [CS.OnAddonLoaded]            = { update_stat_button "CHA" },
                [CS.Charsheet.OnStatsChanged] = { update_stat_button "CHA" }
            }
        }
    }
}

local toggle_frame = function(name)
    if not name then
        return CS.Output.Print "You must specify a frame to toggle."
    end
    name = name:lower()
    if name == "stats" then
        CS.Interface.Toggle(CS_StatsFrame)
    elseif name == "tabs" then
        CS.Interface.ToggleMainFrame()
    elseif name == "edit" then
        CS.Interface.Toggle(CS_EditFrame)
    else
        CS.Output.Print("\"%s\" is not a valid frame.", name)
    end
end

CS.Commands.add_cmd("toggle", toggle_frame, [[
"/cs toggle <frame>" toggles the specified UI frame on or off.
<frame> must be one of: stats, tabs, edit
]])
