local addon_name, CS = ...

local T = CS.Locale.GetLocaleTranslations()

AddonCompartmentFrame:RegisterAddon {
  text         = "Character Sheet",
  icon         = "Interface/Icons/inv_inscription_scroll",
  notCheckable = true,
  func         = function()
    MenuUtil.CreateContextMenu(nil, function(parent, root)
      root:CreateTitle "Character Sheet"
      root:CreateButton("Options", function()
        local title = C_AddOns.GetAddOnMetadata(addon_name, "title")
        Settings.OpenToCategory(title)
      end)
      root:CreateTitle(T.MINIMAP_MENU_UI_FRAMES)
      root:CreateCheckbox(
        T.MINIMAP_MENU_STATS_FRAME,
        function()
          return CS_StatsFrame:IsVisible()
        end,
        function()
          CS.Interface.Toggle(CS_StatsFrame)
        end
      )
      root:CreateCheckbox(
        T.MINIMAP_MENU_EDIT_FRAME,
        function()
          return CS_EditFrame:IsVisible()
        end,
        function()
          CS.Interface.Toggle(CS_EditFrame)
        end
      )
      root:CreateCheckbox(
        T.MINIMAP_MENU_TOGGLE_PET,
        function()
          return CS.Mechanics.Sheet.PetActive
        end,
        function()
          CS.Mechanics.Sheet:toggle_pet()
        end
      )
      root:CreateButton(T.MINIMAP_MENU_RESOURCE, function()
        CS.Interface.ResourceMenu.open()
      end)
    end)
  end,
}
