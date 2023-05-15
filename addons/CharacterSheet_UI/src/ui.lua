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

CS_UI.UI = M
