local addon_name, CS_UI = ...

-- Imports

local UI    = CS_UI.UI
local Sheet = CS_API.Mechanics.Sheet

local Attribute  = CS_API.Mechanics.Statblock.Attribute
local PowerLevel = CS_API.Mechanics.Statblock.PowerLevel

local attribute_to_string   = CS_API.Mechanics.Statblock.attribute_to_string
local subscribe_event       = CS_API.Core.Event.subscribe_event
local translate             = CS_API.Core.Locale.translate

-- Constants

local INCDEC_WIDTH     = 20
local INCDEC_HEIGHT    = 20
local ATTRIBUTE_WIDTH  = 100
local ATTRIBUTE_HEIGHT = 32
local POWER_HEIGHT     = 24
local MARGIN           = 8         
local BORDER_SIZE      = 4
local DEC_TEXTURE      =
  "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP"
local DEC_TEXCOORDS    = {0.0, 0.5, 0.25, 0.5}
local INC_TEXTURE      =
  "Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-PLUSMINUS.BLP"
local INC_TEXCOORDS    = {0.0, 0.5, 0.0, 0.25}
local FRAME_WIDTH
  = 2 * INCDEC_WIDTH
  + ATTRIBUTE_WIDTH
  + 2 * BORDER_SIZE
  + 2 * MARGIN

-- Edit frame definition

local frame = UI.create_frame("CS_UI_EditFrame", UIParent, {
  width    = FRAME_WIDTH;
  height   = POWER_HEIGHT + 6 * ATTRIBUTE_HEIGHT + 2 * BORDER_SIZE;
  x        = 0;
  y        = 0;
  movable  = true;
  backdrop = BACKDROP_TUTORIAL_16_16;
})

frame.power_level_widget =
  UI.create_dropdown("CS_UI_EditFrame_PowerLevel", frame, {
    width   = ATTRIBUTE_WIDTH;
    x       = BORDER_SIZE;
    y       = -BORDER_SIZE;
    get     = function()
      return Sheet.get_active_sheet().statblock.power_level
    end;
    set     = function(value)
      Sheet.set_power_level(Sheet.get_active_sheet(), value)
    end;
    entries = {
      { text  = translate "NOVICE";     value = PowerLevel.NOVICE;     },
      { text  = translate "APPRENTICE"; value = PowerLevel.APPRENTICE; },
      { text  = translate "ADEPT";      value = PowerLevel.ADEPT;      },
      { text  = translate "EXPERT";     value = PowerLevel.EXPERT;     },
      { text  = translate "MASTER";     value = PowerLevel.MASTER;     },
    };
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
  local y_offset      = -BORDER_SIZE - POWER_HEIGHT - (i - 1) * ATTRIBUTE_HEIGHT
  local button_offset = (ATTRIBUTE_HEIGHT - INCDEC_HEIGHT) / 2

  local dec_button = UI.create_icon_button(frame, {
    width     = INCDEC_WIDTH;
    height    = INCDEC_HEIGHT;
    x         = BORDER_SIZE + MARGIN;
    y         = y_offset - button_offset;
    texcoords = DEC_TEXCOORDS;
    texture   = DEC_TEXTURE;
  })

  local label = UI.create_label(frame, {
    width     = ATTRIBUTE_WIDTH;
    height    = ATTRIBUTE_HEIGHT;
    x         = BORDER_SIZE + MARGIN + INCDEC_WIDTH;
    y         = y_offset;
    font      = "Fonts\\ARIALN.ttf";
    font_size = 13;
  })
  label.text:SetText(attribute_to_string(attribute))

  local inc_button = UI.create_icon_button(frame, {
    width     = INCDEC_WIDTH;
    height    = INCDEC_HEIGHT;
    x         = BORDER_SIZE + MARGIN + INCDEC_WIDTH + ATTRIBUTE_WIDTH;
    y         = y_offset - button_offset;
    texcoords = INC_TEXCOORDS;
    texture   = INC_TEXTURE;
  })

  frame.attribute_widgets[attribute] = {
    label      = label;
    dec_button = dec_button;
    inc_button = inc_button;
  }
end

local function update_attribute(attribute, value)
  local label = frame.attribute_widgets[attribute].label
  label.text:SetFormattedText("%s: %d", attribute_to_string(attribute), value)
end

subscribe_event("CS.AttributeChanged", function(sheet, attribute, value)
  update_attribute(attribute, value)
end)

for _, attribute in pairs(Attribute) do
  UI.on_click(frame.attribute_widgets[attribute].dec_button, function()
    local sheet = Sheet.get_active_sheet()
    Sheet.change_attribute(sheet, attribute, -1)
  end)
  UI.on_click(frame.attribute_widgets[attribute].inc_button, function()
    local sheet = Sheet.get_active_sheet()
    Sheet.change_attribute(sheet, attribute, 1)
  end)
end

do
  local sheet = Sheet.get_active_sheet()
  for _, attribute in pairs(Attribute) do
    local value = sheet.statblock.attributes[attribute]
    update_attribute(attribute, value)
  end
end
