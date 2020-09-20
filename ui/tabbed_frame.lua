local addon_name, CS = ...

CS.Interface.ToggleMainFrame = function()
    if CS_MainFrame:IsShown() then
        CS_MainFrame:Hide()
    else
        CS_MainFrame:Show()
    end
end

CS_on_tab_button_clicked = function(name)
    local tab_button = _G[name]
    local index      = tab_button:GetID()
    PanelTemplates_SetTab(CS_MainFrame, index)
    for i = 1, 2 do
        local tab = _G["CS_MainFrame_TabPage" .. i]
        if i == index then
            tab:Show()
        else
            tab:Hide()
        end
    end
end

CS.OnAddonLoaded:add(CS.Interface.ToggleMainFrame)
