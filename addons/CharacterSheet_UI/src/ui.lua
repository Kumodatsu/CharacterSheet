local _, CS_UI = ...
local M = {}

local Sheet     = CS_API.Mechanics.Sheet
local Statblock = CS_API.Mechanics.Statblock

local Attribute = CS_API.Mechanics.Statblock.Attribute

local roll_attribute      = CS_API.Mechanics.Rolls.roll_attribute
local attribute_to_string = CS_API.Mechanics.Statblock.attribute_to_string
local subscribe_event     = CS_API.Core.Event.subscribe_event

local function set_movable(frame, value)
  frame:EnableMouse(value)
  frame:SetMovable(value)
  frame:RegisterForDrag "LeftButton"
  frame:SetScript("OnDragStart", value and function(self)
    self:StartMoving()
  end or nil)
  frame:SetScript("OnDragStop", value and function(self)
    self:StopMovingOrSizing()
  end or nil)
end

local function create_main_frame()
  local HEALTH_WIDTH  = 70
  local HEALTH_HEIGHT = 20
  local INCDEC_WIDTH  = 20
  local INCDEC_HEIGHT = HEALTH_HEIGHT
  local ICON_WIDTH    = 32
  local ICON_HEIGHT   = 32
  local BUTTON_WIDTH  = 110 - ICON_WIDTH
  local BUTTON_HEIGHT = ICON_HEIGHT
  local BORDER_SIZE   = 4

  local HEALTH_TEXTURE = "Interface\\TARGETINGFRAME\\UI-StatusBar"
  local DEC_TEXTURE =
    "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP"
  local DEC_TEXCOORDS = {0.0, 0.5, 0.25, 0.5}
  local INC_TEXTURE =
    "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP"
  local INC_TEXCOORDS = {0.0, 0.5, 0.0, 0.25}

  local ATTRIBUTE_TEXTURES = {
    [Attribute.STR] = "Interface\\ICONS\\Pet_Type_Beast.blp",
    [Attribute.DEX] = "Interface\\ICONS\\Pet_Type_Flying.blp",
    [Attribute.CON] = "Interface\\ICONS\\Pet_Type_Humanoid.blp",
    [Attribute.INT] = "Interface\\ICONS\\Pet_Type_Mechanical.blp",
    [Attribute.WIS] = "Interface\\ICONS\\Pet_Type_Dragon.blp",
    [Attribute.CHA] = "Interface\\ICONS\\Pet_Type_Magical.blp",
  }

  local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  frame:SetBackdrop(BACKDROP_TUTORIAL_16_16)
  --[[
  {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\GLUES\\COMMON\\Glue-Tooltip-Border",
    tile     = true,
    tileSize = 32,
    edgeSize = 16,
    insets   = {
      left   = 16, --BORDER_SIZE,
      right  = 0, --BORDER_SIZE,
      top    = 0, --BORDER_SIZE,
      bottom = 0, --BORDER_SIZE,
    },
  }
  --]]

  frame:SetWidth(ICON_WIDTH + BUTTON_WIDTH + 2 * BORDER_SIZE)
  frame:SetHeight((6 * BUTTON_HEIGHT + HEALTH_HEIGHT) + 2 * BORDER_SIZE)

  set_movable(frame, true)
  frame:SetClampedToScreen(true)
  frame:SetPoint("CENTER", 0, 0)
  frame:Show()

  do
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(INCDEC_WIDTH, INCDEC_HEIGHT)
    button:SetPoint("TOPLEFT", frame, "TOPLEFT", BORDER_SIZE, -BORDER_SIZE)
    button.texture = button:CreateTexture()
    button.texture:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.texture:SetWidth(INCDEC_WIDTH)
    button.texture:SetHeight(INCDEC_HEIGHT)
    button.texture:SetTexCoord(unpack(DEC_TEXCOORDS))
    button.texture:SetTexture(DEC_TEXTURE)
    frame.decrement_health_button = button
  end

  do
    local health_bar = CreateFrame("StatusBar", nil, frame)
    health_bar:SetOrientation "HORIZONTAL"
    health_bar:SetWidth(HEALTH_WIDTH)
    health_bar:SetHeight(HEALTH_HEIGHT)
    health_bar:SetPoint("TOPLEFT", frame, "TOPLEFT",
      BORDER_SIZE + INCDEC_WIDTH, -BORDER_SIZE)
    health_bar:SetStatusBarTexture(HEALTH_TEXTURE)
    health_bar:SetStatusBarColor(0.1, 0.9, 0.3, 1.0)
    health_bar.background = health_bar:CreateTexture(nil, "BACKGROUND")
    health_bar.background:SetTexture(HEALTH_TEXTURE)
    health_bar.background:SetVertexColor(0.0, 0.35, 0.0)
    health_bar.background:SetAllPoints(true)
    health_bar.text = health_bar:CreateFontString(nil, "OVERLAY")
    health_bar.text:SetPoint("CENTER", health_bar, "CENTER", 0, 0)
    health_bar.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    health_bar.text:SetJustifyH "CENTER"
    health_bar.text:SetShadowOffset(1, -1)
    health_bar.text:SetTextColor(0.0, 1.0, 0.0)
    health_bar:Show()

    frame.health_bar = health_bar
  end

  do
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(INCDEC_WIDTH, INCDEC_HEIGHT)
    button:SetPoint("TOPLEFT", frame, "TOPLEFT",
      BORDER_SIZE + INCDEC_WIDTH + HEALTH_WIDTH, -BORDER_SIZE)
    button.texture = button:CreateTexture()
    button.texture:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.texture:SetWidth(INCDEC_WIDTH)
    button.texture:SetHeight(INCDEC_HEIGHT)
    button.texture:SetTexCoord(unpack(INC_TEXCOORDS))
    button.texture:SetTexture(INC_TEXTURE)
    frame.increment_health_button = button
  end

  frame.attribute_widgets = {}
  for i, attribute in ipairs {
    Attribute.STR,
    Attribute.DEX,
    Attribute.CON,
    Attribute.INT,
    Attribute.WIS,
    Attribute.CHA,
  } do
    local y_offset = -BORDER_SIZE - HEALTH_HEIGHT - (i - 1) * BUTTON_HEIGHT

    local icon = CreateFrame("Frame", nil, frame)
    icon:SetSize(ICON_WIDTH, ICON_HEIGHT)
    icon:SetPoint("TOPLEFT", frame, "TOPLEFT", BORDER_SIZE, y_offset)
    icon.texture = icon:CreateTexture(nil, "BACKGROUND")
    icon.texture:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
    icon.texture:SetWidth(ICON_WIDTH)
    icon.texture:SetHeight(ICON_HEIGHT)
    icon.texture:SetTexture(ATTRIBUTE_TEXTURES[attribute])
    icon:Show()

    local button = CreateFrame("Button", nil, frame)
    button:SetWidth(BUTTON_WIDTH)
    button:SetHeight(BUTTON_HEIGHT)
    button:SetPoint("TOPLEFT", frame, "TOPLEFT", BORDER_SIZE + ICON_WIDTH,
      y_offset)
    button:SetNormalFontObject "GameFontNormal"
    button:SetText(attribute_to_string(attribute))
    button:GetFontString():SetPoint("CENTER", button, "CENTER", 0, 0)
    button:SetScript("OnClick", function() roll_attribute(attribute) end)
    button:Show()

    frame.attribute_widgets[attribute] = {
      icon   = icon,
      button = button,
    }
  end
  
  return frame
end

local main_frame = create_main_frame()

local function update_attribute_button(attribute, value)
  local button = main_frame.attribute_widgets[attribute].button
  button:SetFormattedText("%s: %d", attribute_to_string(attribute), value)
end

local function update_health_bar(value, max_value)
  local bar = main_frame.health_bar
  bar.text:SetFormattedText("%d/%d", value, max_value)
  bar:SetMinMaxValues(0, max_value)
  bar:SetValue(value)
end

subscribe_event("CS.AttributeChanged", function(sheet, attribute, value)
  update_attribute_button(attribute, value)
end)

subscribe_event("CS.HPChanged", function(sheet, value)
  update_health_bar(value, Statblock.get_max_hp(sheet.statblock))
end)

subscribe_event("CS.MaxHPChanged", function(sheet, value)
  update_health_bar(sheet.hp, value)
end)

main_frame.decrement_health_button:SetScript("OnClick", function(self)
  local sheet = Sheet.get_active_sheet()
  Sheet.change_hp(sheet, -1)
  update_health_bar(sheet.hp, Statblock.get_max_hp(sheet.statblock))
end)

main_frame.increment_health_button:SetScript("OnClick", function(self)
  local sheet = Sheet.get_active_sheet()
  Sheet.change_hp(sheet, 1)
  update_health_bar(sheet.hp, Statblock.get_max_hp(sheet.statblock))
end)

do
  local sheet = Sheet.get_active_sheet()
  update_health_bar(sheet.hp, Statblock.get_max_hp(sheet.statblock))
  for _, attribute in pairs(Attribute) do
    local value = sheet.statblock.attributes[attribute]
    update_attribute_button(attribute, value)
  end
end

CS_UI.UI = M
