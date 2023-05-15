local addon_name, CS_UI = ...
local M = {}

function M.set_movable(frame, value)
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

function M.on_click(button, handler)
  button:SetScript("OnClick", handler)
end

-- info:
-- { width, height, x, y, movable, backdrop }
function M.create_frame(name, parent, info)
  local item = CreateFrame("Frame", name, parent, "BackdropTemplate")
  M.set_movable(item, info.movable)
  item:SetBackdrop(info.backdrop)
  item:SetWidth(info.width)
  item:SetHeight(info.height)
  item:SetClampedToScreen(true)
  item:SetPoint("CENTER", info.x, info.y)
  return item
end

-- info:
-- { width, height, x, y, texcoords?, texture }
function M.create_icon(parent, info)
  local item = CreateFrame("Frame", nil, parent)
  item:SetSize(info.width, info.height)
  item:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, info.y)
  item.texture = item:CreateTexture(nil, "BACKGROUND")
  item.texture:SetPoint("CENTER", item, "CENTER", 0, 0)
  item.texture:SetWidth(info.width)
  item.texture:SetHeight(info.height)
  if info.texcoords then
    item.texture:SetTexCoord(unpack(info.texcoords))
  else
    item.texture:SetTexCoord(0, 1, 0, 1)
  end
  item.texture:SetTexture(info.texture)
  return item
end

-- info:
-- { width, height, x, y, texcoords?, texture }
function M.create_icon_button(parent, info)
  local item = CreateFrame("Button", nil, parent)
  item:SetSize(info.width, info.height)
  item:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, info.y)
  item.texture = item:CreateTexture()
  item.texture:SetPoint("CENTER", item, "CENTER", 0, 0)
  item.texture:SetWidth(info.width)
  item.texture:SetHeight(info.height)
  if info.texcoords then
    item.texture:SetTexCoord(unpack(info.texcoords))
  else
    item.texture:SetTexCoord(0, 1, 0, 1)
  end
  item.texture:SetTexture(info.texture)
  return item
end

-- info:
-- { width, height, x, y }
function M.create_text_button(parent, info)
  local item = CreateFrame("Button", nil, parent)
  item:SetSize(info.width, info.height)
  item:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, info.y)
  item:SetNormalFontObject "GameFontNormal"
  item:SetText " "
  item:GetFontString():SetPoint("CENTER", item, "CENTER", 0, 0)
  return item
end

-- info:
-- { width, height, x, y, texture, color, bg_color, text_color, font_size }
function M.create_status_bar(parent, info)
  local item = CreateFrame("StatusBar", nil, parent)
  item:SetOrientation "HORIZONTAL"
  item:SetWidth(info.width)
  item:SetHeight(info.height)
  item:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, info.y)
  item:SetStatusBarTexture(info.texture)
  item:SetStatusBarColor(unpack(info.color))
  item.background = item:CreateTexture(nil, "BACKGROUND")
  item.background:SetTexture(info.texture)
  item.background:SetVertexColor(unpack(info.bg_color))
  item.background:SetAllPoints(true)
  item.text = item:CreateFontString(nil, "OVERLAY")
  item.text:SetPoint("CENTER", item, "CENTER", 0, 0)
  item.text:SetFont("Fonts\\FRIZQT__.TTF", info.font_size, "OUTLINE")
  item.text:SetJustifyH "CENTER"
  item.text:SetShadowOffset(1, -1)
  item.text:SetTextColor(unpack(info.text_color))
  return item
end

CS_UI.UI = M
