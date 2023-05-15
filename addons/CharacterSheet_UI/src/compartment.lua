local addon_name, CS_UI = ...

-- Imports

local translate = CS_API.Core.Locale.translate

-- Addon compartment entry definition

local menu = {{
  text         = "Options",
  notCheckable = true,
  func         = function()
    local title = GetAddOnMetadata(addon_name, "title")
    Settings.OpenToCategory(addon_name)
  end,
}, { 
  text         = translate "MINIMAP_MENU_UI_FRAMES",
  isTitle      = true,
  notCheckable = true,
}, {
  text    = translate "MINIMAP_MENU_STATS_FRAME",
  func    = function()
    if CS_UI_StatsFrame:IsVisible() then
      CS_UI_StatsFrame:Hide()
    else
      CS_UI_StatsFrame:Show()
    end
  end,
  checked = function()
    return CS_UI_StatsFrame:IsVisible()
  end,
}, {
  text    = translate "MINIMAP_MENU_EDIT_FRAME",
  func    = function()
    if CS_UI_EditFrame:IsVisible() then
      CS_UI_EditFrame:Hide()
    else
      CS_UI_EditFrame:Show()
    end
  end,
  checked = function()
    return CS_UI_EditFrame:IsVisible()
  end,
}, {
  text    = translate "MINIMAP_MENU_TOGGLE_PET",
  func    = function()
    -- CS.Mechanics.Sheet:toggle_pet()
  end,
  checked = function()
    return false -- return CS.Mechanics.Sheet.PetActive
  end,
}, {
  text         = translate "MINIMAP_MENU_RESOURCE",
  func         = function()
    -- CS.Interface.ResourceMenu.open()
  end,
  notCheckable = true,
}}

AddonCompartmentFrame:RegisterAddon {
  text         = "Character Sheet",
  icon         = "Interface/Icons/inv_inscription_scroll",
  notCheckable = true,
  func         = function()
    EasyMenu(menu, CreateFrame("Frame"), "cursor", 0, 0)
  end,
}
