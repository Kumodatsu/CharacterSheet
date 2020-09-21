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

-- Will be loaded from file on addon load
CS.Interface.UIState.EditFrameVisible = true

local entry_width    = 180
local entry_height   = 32
local entry_count    = #CS.Stats.AttributeNames
local derived_height = 48
local power_height   = 32

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
edit_frame:SetHeight(
    entry_count * entry_height + 11 + 12 + derived_height + power_height
)
edit_frame:SetPoint("CENTER", UIParent, "CENTER")
edit_frame:EnableMouse(true)
edit_frame:SetMovable(true)
edit_frame:RegisterForDrag "LeftButton"
edit_frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
edit_frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
edit_frame:SetClampedToScreen(true)

local power_button = CreateFrame("Button", "CS_PowerButton", edit_frame)
power_button:SetWidth(entry_width)
power_button:SetHeight(power_height)
power_button:SetPoint("TOP", edit_frame, "TOP", 0, -12)
power_button:SetNormalFontObject "GameFontNormal"
power_button:SetText "undefined"
power_button:GetFontString():SetPoint("LEFT", power_button, "LEFT", 0, 0)
power_button:GetFontString():SetPoint("RIGHT", power_button, "RIGHT", 0, 0)

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

local power_select = CreateFrame("Frame", "CS_PowerSelect", power_button)
power_select:SetPoint("TOP", edit_frame, "TOP", 0, -12)
power_select:SetWidth(entry_width)
power_select:SetHeight(power_height)
power_button:SetScript("OnClick", function(self, button, down)
    if button == "LeftButton" then
        EasyMenu(power_menu, power_select, power_select, 0, 0)
    end
end)

edit_frame.power_select = power_select

local entries = {}

local create_entry = function(i)
    local attrib_name = CS.Stats.AttributeNames[i]

    local entry = CreateFrame("Frame", nil, edit_frame)
    if i == 1 then
        entry:SetPoint("TOP", edit_frame, "TOP", 0, -12 - power_height)
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

edit_frame.derived_text = edit_frame:CreateFontString(nil, "OVERLAY")
edit_frame.derived_text:SetPoint("TOP", entries[#entries], "BOTTOM", 0, 0)
edit_frame.derived_text:SetWidth(entry_width)
edit_frame.derived_text:SetHeight(derived_height)
edit_frame.derived_text:SetJustifyH "CENTER"
edit_frame.derived_text:SetJustifyV "CENTER"
edit_frame.derived_text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
edit_frame.derived_text:SetText("HP: 16\nHeal mod: +0\nSP: 0")

CS.Interface.update_edit_frame = function()
    for i = 1, entry_count do
        edit_frame.entries[i].text:SetText(string.format(
            "%s: %d",
            CS.Stats.AttributeNames[i],
            CS.Charsheet.Stats[CS.Stats.AttributeNames[i]]
        ))
    end
    power_button:SetText(CS.Stats.PowerLevel.to_string(CS.Charsheet.Stats.Level))
    edit_frame.derived_text:SetText(string.format(
        "HP: %d\nHeal mod: +%d\nSP: %d",
        CS.Charsheet.Stats:get_max_hp(),
        CS.Charsheet.Stats:get_heal_modifier(),
        CS.Charsheet.Stats:get_remaining_sp()
    ))
end

local initialize_power_select = function()
    UIDropDownMenu_Initialize(power_select, function(dropdown, level, menu_list)
        local info = UIDropDownMenu_CreateInfo()
        info.disabled = nil
        info.text     = "Master"
        info.func     = function() CS.Output.Print "TEST" end
        UIDropDownMenu_AddButton(info, level)
    end)
end

CS.Charsheet.OnStatsChanged
    :add(CS.Interface.update_edit_frame)
CS.OnAddonLoaded
    :add(CS.Interface.update_edit_frame)
    :add(initialize_power_select)
    :add(function()
        if CS.Interface.UIState.EditFrameVisible then
            edit_frame:Show()
        else
            edit_frame:Hide()
        end
    end)
CS.OnAddonUnloading
    :add(function()
        CS.Interface.UIState.EditFrameVisible = edit_frame:IsVisible()
    end)

CS.Interface.ToggleEditFrame = function()
    if edit_frame:IsVisible() then
        edit_frame:Hide()
    else
        edit_frame:Show()
    end
end
