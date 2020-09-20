local addon_name, CS = ...

--[[
local power_level = CreateFrame("Frame", "CS_PowerLevelSelect", UIParent)
local power_level_select = CreateFrame("Button", "CS_PowerLevelSelectButton", power_level)
power_level_select:SetScript("OnClick", function(self)
    ToggleDropDownMenu(1, nil, CS_PowerLevelSelect, CS_PowerLevelSelectButton, 0, 0)
end)
power_level_select:SetScript("OnLoad", function(self)
    UIDropDownMenu_Initialze(self, function(dropdown, level, menu_list)
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true
        info.disabled     = nil
        info.text         = "Master"
        info.func         = function() CS.Output.Print "TEST" end
        UIDropDownMenu_AddButton(info, level)
    end)
end)

power_level:Show()
]]

local entry_width  = 180
local entry_height = 32
local entry_count  = #CS.Stats.AttributeNames

local edit_frame = CreateFrame("Frame", "CS_EditFrame", UIParent)
edit_frame:SetBackdrop {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile     = 1,
    tileSize = 32,
    edgeSize = 32,
    insets   = {
        left   = 11,
        right  = 12,
        top    = 12,
        bottom = 11
    }
}

edit_frame:SetWidth(entry_width + 11 + 12)
edit_frame:SetHeight((entry_count + 1) * entry_height + 11 + 12)
edit_frame:SetPoint("CENTER", UIParent, "CENTER")
edit_frame:EnableMouse(true)
edit_frame:SetMovable(true)
edit_frame:RegisterForDrag "LeftButton"
edit_frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
edit_frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
edit_frame:SetClampedToScreen(true)

local entries = {}

local create_entry = function(i)
    local attrib_name = CS.Stats.AttributeNames[i]

    local entry = CreateFrame("Frame", nil, edit_frame)
    if i == 1 then
        entry:SetPoint("TOP", edit_frame, "TOP", 0, -12)
    else
        entry:SetPoint("TOP", entries[i - 1], "BOTTOM")
    end
    entry:SetSize(entry_width - 64, entry_height)
    entry.text = entry:CreateFontString(nil, "ARTWORK")
    entry.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
    entry.text:SetPoint("CENTER", 0, 0)
    entry.text:SetText(attrib_name)

    local button_dec = CreateFrame("Button", nil, entry)
    button_dec:SetWidth(32)
    button_dec:SetHeight(32)
    button_dec:SetPoint("RIGHT", entry, "LEFT", 0, 0)
    button_dec.texture = button_dec:CreateTexture()
    button_dec.texture:SetPoint("CENTER", button_dec, "CENTER", 0, 0)
    button_dec.texture:SetWidth(32)
    button_dec.texture:SetHeight(32)
    button_dec.texture:SetTexture "Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.blp"
    button_dec:SetScript("OnClick", function()
        CS.Charsheet.set_stat(attrib_name, CS.Charsheet.Stats[attrib_name] - 1)
    end)
    local button_inc = CreateFrame("Button", nil, entry)
    button_inc:SetWidth(32)
    button_inc:SetHeight(32)
    button_inc:SetPoint("LEFT", entry, "RIGHT", 0, 0)
    button_inc.texture = button_inc:CreateTexture()
    button_inc.texture:SetPoint("CENTER", button_inc, "CENTER", 0, 0)
    button_inc.texture:SetWidth(32)
    button_inc.texture:SetHeight(32)
    button_inc.texture:SetTexture "Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.blp"
    button_inc:SetScript("OnClick", function()
        CS.Charsheet.set_stat(attrib_name, CS.Charsheet.Stats[attrib_name] + 1)
    end)
    entry.button_dec = button_dec
    entry.button_inc = button_inc
    entries[i] = entry
    -- "Interface/BUTTONS/UI-SpellbookIcon-PrevPage-Down.blp"
    -- "Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down.blp"
end

for i = 1, entry_count do
    create_entry(i)
end
edit_frame.entries = entries


edit_frame.sp_text = edit_frame:CreateFontString(nil, "OVERLAY")
edit_frame.sp_text:SetPoint("TOP", entries[#entries], "BOTTOM", 0, 0)
edit_frame.sp_text:SetWidth(entry_width)
edit_frame.sp_text:SetHeight(entry_height)
edit_frame.sp_text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
edit_frame.sp_text:SetText("SP: 0")

CS.Interface.update_edit_frame = function()
    for i = 1, entry_count do
        edit_frame.entries[i].text:SetText(string.format(
            "%s: %d",
            CS.Stats.AttributeNames[i],
            CS.Charsheet.Stats[CS.Stats.AttributeNames[i]]
        ))
    end
    edit_frame.sp_text:SetText(string.format(
        "SP: %d",
        CS.Charsheet.Stats:get_remaining_sp()
    ))
end

CS.Charsheet.OnStatsChanged:add(CS.Interface.update_edit_frame)
CS.OnAddonLoaded:add(CS.Interface.update_edit_frame)

CS.Interface.ToggleEditFrame = function()
    if edit_frame:IsVisible() then
        edit_frame:Hide()
    else
        edit_frame:Show()
    end
end
