local addon_name, CS = ...

-- Will be loaded from file on addon load
CS.Interface.UIState.StatsFrameVisible = true

local stat_icons = {
    "Interface\\ICONS\\Icon_PetFamily_Beast.blp",
    "Interface\\ICONS\\Icon_PetFamily_Flying.blp",
    "Interface\\ICONS\\Icon_PetFamily_Humanoid.blp",
    "Interface\\ICONS\\Icon_PetFamily_Mechanical.blp",
    "Interface\\ICONS\\Icon_PetFamily_Dragon.blp",
    "Interface\\ICONS\\Icon_PetFamily_Magical.blp"
}
local entry_width  = 110
local entry_height = 32
local entry_count  = #CS.Stats.AttributeNames

local buttons = {}

local stats_frame = CreateFrame("Frame", "CS_StatsFrame", UIParent)

stats_frame:SetBackdrop {
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

stats_frame:SetWidth(entry_width + 11 + 12)
stats_frame:SetHeight(entry_count * entry_height + 11 + 12 + 20)
stats_frame:SetPoint("CENTER", UIParent, "CENTER")
stats_frame:EnableMouse(true)
stats_frame:SetMovable(true)
stats_frame:RegisterForDrag "LeftButton"
stats_frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
stats_frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
stats_frame:SetClampedToScreen(true)

local health_bar = CreateFrame("StatusBar", nil, stats_frame)
health_bar:SetPoint("TOP", stats_frame, "TOP", 0, -12)
health_bar:SetOrientation "HORIZONTAL"
health_bar:SetWidth(entry_width)
health_bar:SetHeight(20)
health_bar:SetStatusBarTexture "Interface\\TARGETINGFRAME\\UI-StatusBar"
health_bar:SetStatusBarColor(0.1, 0.9, 0.3, 1.0)

health_bar.background = health_bar:CreateTexture(nil, "BACKGROUND")
health_bar.background:SetTexture "Interface\\TARGETINGFRAME\\UI-StatusBar"
health_bar.background:SetAllPoints(true)
health_bar.background:SetVertexColor(0, 0.35, 0)

health_bar.text = health_bar:CreateFontString(nil, "OVERLAY")
health_bar.text:SetPoint("CENTER", health_bar, "CENTER", 0, 0)
health_bar.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
health_bar.text:SetJustifyH "CENTER"
health_bar.text:SetShadowOffset(1, -1)
health_bar.text:SetTextColor(0.0, 1.0, 0.0)

stats_frame.health_bar = health_bar

local create_button = function(i)
    local button = CreateFrame("Button", nil, stats_frame)
    if i == 1 then
        button:SetPoint("TOP", stats_frame, "TOP", 0, -32)
    else
        button:SetPoint("TOP", buttons[i - 1], "BOTTOM")
    end
    button:SetNormalFontObject "GameFontNormal"
    button:SetText "undefined"
    button:GetFontString():SetPoint("LEFT", button, "LEFT", 32, 0)
    button:GetFontString():SetPoint("RIGHT", button, "RIGHT", 0, 0)
    button:SetSize(entry_width, entry_height)
    button.texture = button:CreateTexture()
    button.texture:SetPoint "TOPLEFT"
    button.texture:SetWidth(32)
    button.texture:SetHeight(32)
    button.texture:SetTexture(stat_icons[i])
    button:SetScript("OnClick", function()
        CS.Charsheet.roll_stat(CS.Stats.AttributeNames[i])
    end)
    button:Show()
    buttons[i] = button
end

for i = 1, entry_count do
    create_button(i)
end

CS.Interface.update_hp_indicator = function()
    local hp     = CS.Charsheet.CurrentHP
    local hp_max = CS.Charsheet.Stats:get_max_hp()
    local text   = string.format("%d/%d", hp, hp_max)
    stats_frame.health_bar.text:SetText(text)
    stats_frame.health_bar:SetMinMaxValues(0, hp_max)
    stats_frame.health_bar:SetValue(hp)
end

CS.Interface.update_stats_buttons = function()
    for i = 1, entry_count do
        buttons[i]:SetText(string.format(
            "%s: %d",
            CS.Stats.AttributeNames[i],
            CS.Charsheet.Stats[CS.Stats.AttributeNames[i]]
        ))
    end
end

CS.Charsheet.OnStatsChanged
    :add(CS.Interface.update_stats_buttons)
CS.Charsheet.OnHPChanged
    :add(CS.Interface.update_hp_indicator)
CS.OnAddonLoaded
    :add(CS.Interface.update_hp_indicator)
    :add(CS.Interface.update_stats_buttons)
    :add(function()
        if CS.Interface.UIState.StatsFrameVisible then
            stats_frame:Show()
        else
            stats_frame:Hide()
        end
    end)
CS.OnAddonUnloading
    :add(function()
        CS.Interface.UIState.StatsFrameVisible = stats_frame:IsVisible()
    end)

CS.Interface.ToggleStatsFrame = function()
    if stats_frame:IsVisible() then
        stats_frame:Hide()
    else
        stats_frame:Show()
    end
end

local toggle_frame = function(name)
    if not name then
        return CS.Output.Print "You must specify a frame to toggle."
    end
    name = name:lower()
    if name == "stats" then
        CS.Interface.ToggleStatsFrame()
    elseif name == "tabs" then
        CS.Interface.ToggleMainFrame()
    elseif name == "edit" then
        CS.Interface.ToggleEditFrame()
    else
        CS.Output.Print("\"%s\" is not a valid frame.", name)
    end
end

CS.Commands.add_cmd("toggle", toggle_frame, [[
"/cs toggle <frame>" toggles the specified UI frame on or off.
<frame> must be one of: stats, tabs, edit
]])
