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
    if main_frame:IsVisible() then
      main_frame:Hide()
    else
      main_frame:Show()
    end
  end,
  checked = function()
    return main_frame:IsVisible()
  end,
}, {
  text    = translate "MINIMAP_MENU_EDIT_FRAME",
  func    = function()
    -- CS.Interface.Toggle(CS_EditFrame)
  end,
  checked = function()
    return false -- return CS_EditFrame:IsVisible()
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
