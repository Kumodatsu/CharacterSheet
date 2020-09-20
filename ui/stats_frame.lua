local addon_name, CS = ...
local M = {}

local stat_names = { "STR", "DEX", "CON", "INT", "WIS", "CHA" }
local entry_width  = 110
local entry_height = 32
local entry_count  = #stat_names

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
stats_frame:SetHeight(entry_count * entry_height + 11 + 12)
stats_frame:SetPoint("CENTER", UIParent, "CENTER")
stats_frame:EnableMouse(true)
stats_frame:SetMovable(true)
stats_frame:RegisterForDrag "LeftButton"
stats_frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
stats_frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
stats_frame:SetClampedToScreen(true)

local create_button = function(i)
    local button = CreateFrame("Button", nil, stats_frame)
    if i == 1 then
        button:SetPoint("TOP", stats_frame, "TOP", 0, -12)
    else
        button:SetPoint("TOP", buttons[i - 1], "BOTTOM")
    end
    button:SetNormalFontObject "GameFontNormal"
    button:SetSize(entry_width, entry_height)
    button.texture = button:CreateTexture()
    button.texture:SetPoint "TOPLEFT"
    button.texture:SetWidth(32)
    button.texture:SetHeight(32)
    button.texture:SetTexture(nil)
    button:SetScript("OnClick", function()
        CS.Charsheet.roll_stat(stat_names[i])
    end)
    button:Show()
    buttons[i] = button
end

for i = 1, entry_count do
    create_button(i)
end

M.UpdateStatsButtons = function()
    for i = 1, entry_count do
        buttons[i]:SetText(string.format(
            "%s: %d",
            stat_names[i],
            CS.Charsheet.Stats[stat_names[i]]
        ))
    end
end

stats_frame:Show()

CS.Charsheet.OnStatsChanged:add(M.UpdateStatsButtons)
CS.OnAddonLoaded:add(M.UpdateStatsButtons)

M.ToggleStatsFrame = function()
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
        M.ToggleStatsFrame()
    elseif name == "tabs" then
        if CS_MainFrame:IsShown() then
            CS_MainFrame:Hide()
        else
            CS_MainFrame:Show()
        end
    else
        CS.Output.Print("\"%s\" is not a valid frame.", name)
    end
end

CS.Commands.add_cmd("toggle", toggle_frame, [[
"/cs toggle <frame>" toggles the specified UI frame on or off.
<frame> must be one of: stats, tabs
]])

CS.Interface = M
