local addon_name, CS = ...

local T = CS.Locale.GetLocaleTranslations()

-- Global addon accessor
CS_API = CS

-- Key bindings
BINDING_HEADER_CHARACTER_SHEET  = T.KEYBIND_HEADER
BINDING_NAME_INCREMENT_HP       = T.KEYBIND_INCREMENT_HP
BINDING_NAME_DECREMENT_HP       = T.KEYBIND_DECREMENT_HP
BINDING_NAME_INCREMENT_PET_HP   = T.KEYBIND_INCREMENT_PET_HP
BINDING_NAME_DECREMENT_PET_HP   = T.KEYBIND_DECREMENT_PET_HP
BINDING_NAME_TOGGLE_PET         = T.KEYBIND_TOGGLE_PET
BINDING_NAME_TOGGLE_STATS_FRAME = T.KEYBIND_TOGGLE_STATS_FRAME
BINDING_NAME_TOGGLE_EDIT_FRAME  = T.KEYBIND_TOGGLE_EDIT_FRAME

-- Version command
local show_version = function()
    local author  = GetAddOnMetadata(addon_name, "author")
    local title   = GetAddOnMetadata(addon_name, "title")
    local version = GetAddOnMetadata(addon_name, "version")
    CS.Print(T.ADDON_INFO(author, title, version))
end

CS.Commands.add_cmd("version", show_version, [[
"/cs version" shows the addon's current version number.
]])

-- Dependencies
local Ace = {
    Addon        = LibStub "AceAddon-3.0",
    Config       = LibStub "AceConfig-3.0",
    ConfigDialog = LibStub "AceConfigDialog-3.0",
}

local Lib = {
  DataBroker   = LibStub "LibDataBroker-1.1",
  DBIcon       = LibStub "LibDBIcon-1.0",
}

local mixins = {}

CS_ADDON = Ace.Addon
    : NewAddon(addon_name, unpack(mixins))

local spacer = function(i)
    return {
        order     = i,
        name      = "",
        type      = "description",
        width     = "full",
        cmdHidden = true
    }
end

local options = {
    name    = addon_name,
    handler = CS_ADDON,
    type    = "group",
    args    = {
        raid_rolls = {
            order = 0,
            name  = T.SETTING_RAID_ROLLS,
            desc  = T.SETTING_RAID_ROLLS_DESC,
            type  = "toggle",
            get   = function(info)
                return CS.Roll.RaidRollsEnabled
            end,
            set   = function(info, value)
                CS.Roll.RaidRollsEnabled = value
            end
        },
        spacer1 = spacer(1)
    }
}

local trp3 = CS.Extensions.totalRP3
if trp3 then
    local StatUpdateState = trp3.StatUpdateState
    options.args.trp_stats = {
        name   = T.SETTING_TRP_STATS,
        desc   = T.SETTING_TRP_STATS_DESC,
        type   = "select",
        style  = "dropdown",
        get    = function(info)
            return trp3.UpdateTRPWithStats
        end,
        set    = function(info, value)
            trp3.UpdateTRPWithStats = value
        end,
        values = {
            [StatUpdateState.None]      = T.SETTING_TRP_STATS_DISABLED,
            [StatUpdateState.Currently] = T.SETTING_TRP_STATS_CURRENTLY,
            [StatUpdateState.OOC]       = T.SETTING_TRP_STATS_OOC
        }
    }
end

local data_broker = Lib.DataBroker:NewDataObject("CharacterSheet", {
  type = "data source",
  text = "CharacterSheet",
  icon = "Interface/Icons/inv_inscription_scroll",
  OnClick = function()
    local menu = {
      { text = "UI frames", isTitle = true },
      { text = "Stats frame",
        func = function()
          CS.Interface.Toggle(CS_StatsFrame)
        end,
        checked = function()
          return CS_StatsFrame:IsVisible()
        end,
      },
      { text = "Edit frame",
        func = function()
          CS.Interface.Toggle(CS_EditFrame)
        end,
        checked = function()
          return CS_EditFrame:IsVisible()
        end,
      },
    }
    EasyMenu(menu, CreateFrame("FRAME", "CS_MinimapMenu"), "cursor", 0, 0, nil)
  end,
  OnTooltipShow = function(self)
    self:AddLine "CharacterSheet"
    self:AddLine "Peekaboo."
  end,
})

CS_ADDON.OnInitialize = function(self)
  Ace.Config:RegisterOptionsTable(addon_name, options)
  self.options_frame = Ace.ConfigDialog
    : AddToBlizOptions(addon_name, GetAddOnMetadata(addon_name, "title"))
  CS_MinimapState = CS_MinimapState or {}
  Lib.DBIcon:Register("CharacterSheet", data_broker, CS_MinimapState)
end