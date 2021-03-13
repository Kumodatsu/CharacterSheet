local addon_name, CS_UI = ...
CS_UI.Interface = {}

local M = CS_UI.Interface

M.UIState = {}

local register_events = function(frame, events)
    if not events then return end
    for event, callbacks in pairs(events) do
        for _, callback in ipairs(callbacks) do
            event:add(function(...) callback(frame, ...) end)
        end
    end
end

local register_scripts = function(frame, scripts)
    if not scripts then return end
    for name, script in pairs(scripts) do
        frame[name] = script
        frame:SetScript(name, script)
    end
end

local register_tooltip = function(frame, content)
    if not content then return end
    local on_enter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(content)
        GameTooltip:Show()
    end
    local on_leave = function(self)
        GameTooltip:Hide()
    end
    local original_on_enter = frame.OnEnter
    local original_on_leave = frame.OnLeave
    frame.OnEnter = not original_on_enter and on_enter or function(self)
        original_on_enter(self)
        on_enter(self)
    end
    frame.OnLeave = not original_on_leave and on_leave or function(self)
        original_on_leave(self)
        on_leave(self)
    end
    frame:SetScript("OnEnter", frame.OnEnter)
    frame:SetScript("OnLeave", frame.OnLeave)
end

local register_all = function(frame, info)
    register_events(frame, info.Events)
    register_scripts(frame, info.Scripts)
    register_tooltip(frame, info.Tooltip)
end

M.Frame = function(info, parent)
    local use_backdrop = info.Backdrop and BackdropTemplateMixin and true
        or false
    local frame  = CreateFrame("Frame", info.Global or nil, parent or UIParent,
        use_backdrop and "BackdropTemplate" or nil)
    local width  = info.Width
    local height = info.Height
    if use_backdrop then
        frame:SetBackdrop {
            bgFile   = info.Backdrop.Background,
            edgeFile = info.Backdrop.Edges,
            tile     = info.Backdrop.Tiled,
            tileSize = info.Backdrop.TileSize,
            edgeSize = info.Backdrop.EdgeSize,
            insets   = {
                left   = info.Backdrop.Insets.Left,
                right  = info.Backdrop.Insets.Right,
                top    = info.Backdrop.Insets.Top,
                bottom = info.Backdrop.Insets.Bottom
            }
        }
        width  = width + info.Backdrop.Insets.Left + info.Backdrop.Insets.Right
        if height ~= Automatic then
            height = height + info.Backdrop.Insets.Top + info.Backdrop.Insets.Bottom
        end
    end
    frame:SetWidth(width)
    if height ~= Automatic then
        frame:SetHeight(height)
    end
    info.Point = info.Point or { "CENTER", UIParent, "CENTER" }
    frame:SetPoint(info.Point[1], info.Point[2], info.Point[3], info.Point[4],
        info.Point[5])
    if info.Movable then
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag "LeftButton"
        frame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)
    end
    frame:SetClampedToScreen(info.Clamped)

    local x = 0
    local y = 0
    local offset_x = 0
    local offset_y = 0
    local c_height = 0
    if info.Backdrop then
        offset_x = info.Backdrop.Insets.Left
        offset_y = -info.Backdrop.Insets.Top
    end
    
    local configure = function(content)
        content:SetParent(frame)
        local c_width = CS_API.Util.round(content:GetWidth())
        local new_x   = x + c_width
        local wrap    = new_x > info.Width
        if wrap then
            x = 0
            y = y - c_height
        end
        content:SetPoint("TOPLEFT", frame, "TOPLEFT", x + offset_x, y + offset_y)
        x = wrap and c_width or new_x
        c_height = CS_API.Util.round(content:GetHeight())
    end
    for _, content in ipairs(info.Content) do
        if type(content) == "function" then
            for inner in content do
                configure(inner)
            end
        else
            configure(content)
        end
    end
    register_all(frame, info)
    return frame
end

M.Button = function(info)
    local button = CreateFrame("Button", info.Global or nil, nil)
    button:SetSize(info.Width, info.Height)
    if info.OnClick then
        button:SetScript("OnClick", info.OnClick)
    end
    if info.Texture then
        button.texture = button:CreateTexture()
        button.texture:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.texture:SetWidth(info.Width)
        button.texture:SetHeight(info.Height)
        if info.TexCoords then
            button.texture:SetTexCoord(info.TexCoords[1], info.TexCoords[2],
                info.TexCoords[3], info.TexCoords[4])
        end
        button.texture:SetTexture(info.Texture)
    end
    if info.Text then
        button:SetNormalFontObject "GameFontNormal"
        button:SetText(info.Text)
        button:GetFontString():SetPoint("CENTER", button, "CENTER", 0, 0)
    end
    register_all(button, info)
    return button
end

M.Checkbox = function(info)
    local button = CreateFrame("Button", info.Global or nil, nil)
    button.checked = false
    button:SetSize(info.Width, info.Height)
    button:SetScript("OnClick", function(self)
        button.checked = not button.checked
        local texture_info = button.checked and info.Enabled or info.Disabled
        if texture_info.TexCoords then
            button.texture:SetTexCoord(
                texture_info.TexCoords[1],
                texture_info.TexCoords[2],
                texture_info.TexCoords[3],
                texture_info.TexCoords[4]
            )
        end
        if texture_info.Color then
            local color      = texture_info.Color or { 1.0, 1.0, 1.0, 1.0 }
            local r, g, b, a = unpack(color)
            button.texture:SetVertexColor(r, g, b, a)
        end
        button.texture:SetTexture(texture_info.Texture)
        if info.OnClick then
            info.OnClick(self)
        end
    end)
    if info.Enabled and info.Disabled then
        button.texture = button:CreateTexture()
        button.texture:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.texture:SetWidth(info.Width)
        button.texture:SetHeight(info.Height)
        if info.Disabled.TexCoords then
            button.texture:SetTexCoord(info.TexCoords[1], info.TexCoords[2],
                info.TexCoords[3], info.TexCoords[4])
        end
        if info.Disabled.Color then
            local color      = info.Disabled.Color or { 1.0, 1.0, 1.0, 1.0 }
            local r, g, b, a = unpack(color)
            button.texture:SetVertexColor(r, g, b, a)
        end
        button.texture:SetTexture(info.Disabled.Texture)
    end
    register_all(button, info)
    return button
end

M.StatusBar = function(info)
    local bar = CreateFrame("StatusBar", info.Global or nil, nil)
    bar:SetOrientation(info.Orientation)
    bar:SetWidth(info.Width)
    bar:SetHeight(info.Height)
    bar:SetStatusBarTexture(info.Foreground.Texture)
    local color = info.Foreground.Color
    bar:SetStatusBarColor(color[1], color[2], color[3], color[4])
    bar.background = bar:CreateTexture(nil, "BACKGROUND")
    bar.background:SetTexture(info.Background.Texture)
    color = info.Background.Color
    bar.background:SetVertexColor(color[1], color[2], color[3])
    bar.background:SetAllPoints(true)
    bar.text = bar:CreateFontString(nil, "OVERLAY")
    bar.text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    bar.text:SetJustifyH "CENTER"
    bar.text:SetShadowOffset(1, -1)
    local text_color = info.TextColor or { 1.0, 1.0, 1.0 }
    bar.text:SetTextColor(unpack(text_color))
    register_all(bar, info)
    return bar
end

M.Icon = function(info)
    local icon = CreateFrame("Frame", info.Global or nil, nil)
    icon:SetSize(info.Width, info.Height)
    icon.texture = icon:CreateTexture(nil, "BACKGROUND")
    icon.texture:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
    icon.texture:SetWidth(info.Width)
    icon.texture:SetHeight(info.Height)
    if info.TexCoords then
        icon.texture:SetTexCoord(info.TexCoords[1], info.TexCoords[2],
            info.TexCoords[3], info.TexCoords[4])
    end
    icon.texture:SetTexture(info.Texture)
    register_all(icon, info)
    return icon
end

M.Text = function(info)
    local frame = CreateFrame("Frame", info.Global or nil, nil)
    frame:SetSize(info.Width, info.Height)
    frame.text = frame:CreateFontString(nil, "ARTWORK")
    frame.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
    frame.text:SetPoint("CENTER", 0, 0)
    frame.text:SetText(info.Text or "")
    register_all(frame, info)
    return frame
end

M.Dropdown = function(info)
    local dropdown = CreateFrame("Button", info.Global, nil)
    dropdown:SetWidth(info.Width)
    dropdown:SetHeight(info.Height)
    dropdown:SetNormalFontObject "GameFontNormal"
    dropdown:SetText(info.Text or "undefined")
    dropdown:GetFontString():SetPoint("LEFT", dropdown, "LEFT", 0, 0)
    dropdown:GetFontString():SetPoint("RIGHT", dropdown, "RIGHT", 0, 0)

    dropdown.select = CreateFrame("Frame", info.Global .. "Select", dropdown)
    dropdown.select:SetPoint("TOP", dropdown, "TOP", 0, 0)
    dropdown.select:SetWidth(info.Width)
    dropdown.select:SetHeight(info.Height)

    dropdown:SetScript("OnClick", function(self, button, down)
        if button == "LeftButton" then
            EasyMenu(info.Menu, dropdown.select, dropdown.select, 0, 0)
        end
    end)

    register_all(dropdown, info)
    return dropdown
end

M.Toggle = function(frame, visible)
    if visible == nil then
        if frame:IsVisible() then
            frame:Hide()
            return false
        else
            frame:Show()
            return true
        end
    elseif visible then
        frame:Show()
    else
        frame:Hide()
    end
    return visible
end

local toggle_frame = function(name)
    if not name then
        return CS_API.print "You must specify a frame to toggle."
    end
    --[[
    name = name:lower()
    if name == "stats" then
        CS.Interface.Toggle(CS_StatsFrame)
    elseif name == "edit" then
        CS.Interface.Toggle(CS_EditFrame)
    else
        CS.Print("\"%s\" is not a valid frame.", name)
    end
    ]]
end

CS_API.Command.add_cmd("toggle", toggle_frame, [[
"/cs toggle <frame>" toggles the specified UI frame on or off.
<frame> must be one of: stats, edit
]])
