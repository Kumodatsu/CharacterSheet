local addon_name, CS = ...

local T = CS.Locale.GetLocaleTranslations()

local Ace = {
  GUI = LibStub "AceGUI-3.0",
}

local M = {}

M.open = function()
  if tf and tf:IsVisible() then return end

  tf = Ace.GUI:Create "Frame"
  tf:SetCallback("OnClose", function(widget) widget:Hide() end)
  tf:SetTitle(T.RESOURCE_MENU_TITLE)
  tf:SetLayout "Flow"
  tf:SetWidth(450)
  tf:SetHeight(240)
  tf:EnableResize(false)
  
  local label = function(text)
    local l = Ace.GUI:Create "Label"
    l:SetText(text)
    tf:AddChild(l)
    return l
  end

  local inputbox = function(text)
    text = text or ""
    local e = Ace.GUI:Create "EditBox"
    e:SetWidth(200)
    e:SetText(text)
    tf:AddChild(e)
    return e
  end

  local colorpicker = function(color)
    local cp = Ace.GUI:Create "ColorPicker"
    if color then cp:SetColor(color[1], color[2], color[3], color[4]) end
    tf:AddChild(cp)
    return cp
  end

  local get_color = function(picker)
    return { picker.r, picker.g, picker.b, 1.0 }
  end
  
  local res = CS.Mechanics.Sheet.Resource
  local data = {
    Name      = res and res.Name or "",
    Min       = res and res.Min or 0,
    Max       = res and res.Max or 10,
    Color     = res and res.Color or { 1.0, 0.65, 0.0, 1.0 },
    TextColor = res and res.TextColor or { 0.1, 0.3,  0.9, 1.0 },
  }

  label(T.RESOURCE_MENU_NAME)
  local input_name = inputbox(data.Name)
  label(T.RESOURCE_MENU_MIN)
  local input_min  = inputbox(data.Min)
  label(T.RESOURCE_MENU_MAX)
  local input_max  = inputbox(data.Max)
  label(T.RESOURCE_MENU_BACKGROUND_COLOR)
  local cbg = colorpicker(data.Color)
  label(T.RESOURCE_MENU_TEXT_COLOR)
  local cfg = colorpicker(data.TextColor)

  local update_resource = function()
    local name = input_name:GetText()
    if not name or #name == 0 then
      tf:SetStatusText(
        string.format("|cFFFF0000%s|r", T.RESOURCE_MENU_MISSING_NAME)
      )
      return
    end
    local min = tonumber(input_min:GetText())
    local max = tonumber(input_max:GetText())
    if not min or not max or not CS.Math.is_integer(min) or not CS.Math.is_integer(max) then
      tf:SetStatusText(
        string.format("|cFFFF0000%s|r", T.RESOURCE_MENU_INVALID_INPUT)
      )
      return
    end
    if min >= max then
      tf:SetStatusText(
        string.format("|cFFFF0000%s|r", T.RESOURCE_MENU_INVALID_RANGE)
      )
      return
    end
    tf:SetStatusText ""
    CS.Mechanics.Sheet:add_resource(
      name,
      min,
      max,
      get_color(cbg),
      get_color(cfg)
    )
  end

  input_name:SetCallback("OnEnterPressed", update_resource)
  input_min:SetCallback("OnEnterPressed", update_resource)
  input_max:SetCallback("OnEnterPressed", update_resource)
  cbg:SetCallback("OnValueChanged", update_resource)
  cfg:SetCallback("OnValueChanged", update_resource)

  local remove_resource = function()
    CS.Mechanics.Sheet:remove_resource()
  end

  local b = Ace.GUI:Create "Button"
  b:SetWidth(170)
  b:SetText(T.RESOURCE_MENU_DISABLE)
  b:SetCallback("OnClick", remove_resource)
  tf:AddChild(b)
end

M.close = function()
  if tf then tf:Hide() end
end

M.toggle = function()
  if not tf then return end
  if tf:IsVisible() then
    M.close()
  else
    M.open()
  end
end

CS.Interface.ResourceMenu = M
