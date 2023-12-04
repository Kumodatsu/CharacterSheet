local addon_name, CS = ...

local T = CS.Locale.GetLocaleTranslations()

local menu = {
  {
    text         = "Options",
    notCheckable = true,
    func         = function()
      local title = GetAddOnMetadata(addon_name, "title")
      -- Have to call this function twice because of a WoW API-side bug.
      InterfaceOptionsFrame_OpenToCategory(title)
      InterfaceOptionsFrame_OpenToCategory(title)
    end,
  },
  {
    text         = T.MINIMAP_MENU_UI_FRAMES,
    isTitle      = true,
    notCheckable = true,
  },
  {
    text = T.MINIMAP_MENU_STATS_FRAME,
    func = function()
      CS.Interface.Toggle(CS_StatsFrame)
    end,
    checked = function()
      return CS_StatsFrame:IsVisible()
    end,
  },
  {
    text = T.MINIMAP_MENU_EDIT_FRAME,
    func = function()
      CS.Interface.Toggle(CS_EditFrame)
    end,
    checked = function()
      return CS_EditFrame:IsVisible()
    end,
  },
  {
    text = T.MINIMAP_MENU_TOGGLE_PET,
    func = function()
      CS.Mechanics.Sheet:toggle_pet()
    end,
    checked = function()
      return CS.Mechanics.Sheet.PetActive
    end,
  },
  {
    text = T.MINIMAP_MENU_RESOURCE,
    func = function()
      CS.Interface.ResourceMenu.open()
    end,
    notCheckable = true,
  },
}

AddonCompartmentFrame:RegisterAddon {
  text         = "Character Sheet",
  icon         = "Interface/Icons/inv_inscription_scroll",
  notCheckable = true,
  func         = function()
    EasyMenu(menu, CreateFrame "Frame", "cursor", 0, 0)
  end,
}
