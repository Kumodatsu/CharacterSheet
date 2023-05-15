local addon_name, CS_UI = ...

-- Imports

local UI        = CS_UI.UI
local Sheet     = CS_API.Mechanics.Sheet
local Statblock = CS_API.Mechanics.Statblock

local Attribute = CS_API.Mechanics.Statblock.Attribute

local roll_attribute      = CS_API.Mechanics.Rolls.roll_attribute
local attribute_to_string = CS_API.Mechanics.Statblock.attribute_to_string
local subscribe_event     = CS_API.Core.Event.subscribe_event
local translate           = CS_API.Core.Locale.translate

-- Constants

local HEALTH_WIDTH       = 70
local HEALTH_HEIGHT      = 20
local INCDEC_WIDTH       = 20
local INCDEC_HEIGHT      = HEALTH_HEIGHT
local ICON_WIDTH         = 32
local ICON_HEIGHT        = 32
local BUTTON_WIDTH       = 110 - ICON_WIDTH
local BUTTON_HEIGHT      = ICON_HEIGHT
local BORDER_SIZE        = 4
local HEALTH_TEXTURE     = "Interface\\TARGETINGFRAME\\UI-StatusBar"
local DEC_TEXTURE        =
  "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP"
local DEC_TEXCOORDS      = {0.0, 0.5, 0.25, 0.5}
local INC_TEXTURE        =
  "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP"
local INC_TEXCOORDS      = {0.0, 0.5, 0.0, 0.25}
local ATTRIBUTE_TEXTURES = {
  [Attribute.STR] = "Interface\\ICONS\\Pet_Type_Beast.blp",
  [Attribute.DEX] = "Interface\\ICONS\\Pet_Type_Flying.blp",
  [Attribute.CON] = "Interface\\ICONS\\Pet_Type_Humanoid.blp",
  [Attribute.INT] = "Interface\\ICONS\\Pet_Type_Mechanical.blp",
  [Attribute.WIS] = "Interface\\ICONS\\Pet_Type_Dragon.blp",
  [Attribute.CHA] = "Interface\\ICONS\\Pet_Type_Magical.blp",
}

-- Frame definition

local frame = UI.create_frame("CS_UI_StatsFrame", UIParent, {
  width    = ICON_WIDTH + BUTTON_WIDTH + 2 * BORDER_SIZE;
  height   = 6 * BUTTON_HEIGHT + HEALTH_HEIGHT + 2 * BORDER_SIZE;
  x        = 0;
  y        = 0;
  movable  = true;
  backdrop = BACKDROP_TUTORIAL_16_16;
})

frame.decrement_health_button = UI.create_icon_button(frame, {
  width     = INCDEC_WIDTH;
  height    = INCDEC_HEIGHT;
  x         = BORDER_SIZE;
  y         = -BORDER_SIZE;
  texcoords = DEC_TEXCOORDS;
  texture   = DEC_TEXTURE;
})

frame.health_bar = UI.create_status_bar(frame, {
  width      = HEALTH_WIDTH;
  height     = HEALTH_HEIGHT;
  x          = BORDER_SIZE + INCDEC_WIDTH;
  y          = -BORDER_SIZE;
  texture    = HEALTH_TEXTURE;
  color      = {0.1, 0.9,  0.3};
  bg_color   = {0.0, 0.35, 0.0};
  text_color = {0.0, 1.0,  0.0};
  font_size  = 16;
})

frame.increment_health_button = UI.create_icon_button(frame, {
  width     = INCDEC_WIDTH;
  height    = INCDEC_HEIGHT;
  x         = BORDER_SIZE + INCDEC_WIDTH + HEALTH_WIDTH;
  y         = -BORDER_SIZE;
  texcoords = INC_TEXCOORDS;
  texture   = INC_TEXTURE;
})

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

  local icon = UI.create_icon(frame, {
    width   = ICON_WIDTH;
    height  = ICON_HEIGHT;
    x       = BORDER_SIZE;
    y       = y_offset;
    texture = ATTRIBUTE_TEXTURES[attribute];
  })
  local button = UI.create_text_button(frame, {
    width  = BUTTON_WIDTH;
    height = BUTTON_HEIGHT;
    x      = BORDER_SIZE + ICON_WIDTH;
    y      = y_offset;
  })
  button:SetText(attribute_to_string(attribute))
  UI.on_click(button, function() roll_attribute(attribute) end)
  frame.attribute_widgets[attribute] = {
    icon   = icon,
    button = button,
  }
end

local function update_attribute_button(attribute, value)
  local button = frame.attribute_widgets[attribute].button
  button:SetFormattedText("%s: %d", attribute_to_string(attribute), value)
end

local function update_health_bar(value, max_value)
  local bar = frame.health_bar
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

UI.on_click(frame.decrement_health_button, function()
  local sheet = Sheet.get_active_sheet()
  Sheet.change_hp(sheet, -1)
  update_health_bar(sheet.hp, Statblock.get_max_hp(sheet.statblock))
end)

UI.on_click(frame.increment_health_button, function()
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
