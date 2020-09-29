local addon_name, CS = ...

CS.Interface = {
    UIState = {}
}

local register_events = function(frame, events)
    if not events then return end
    for event, callbacks in pairs(events) do
        for _, callback in ipairs(callbacks) do
            event:add(function(...) callback(frame, ...) end)
        end
    end
end

CS.Interface.Frame = function(info)
    local frame  = CreateFrame("Frame", info.Global or nil, UIParent)
    local width  = info.Width
    local height = info.Height
    if info.Backdrop then
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
    frame:SetPoint(info.Point[1], info.Point[2], info.Point[3])
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
    for _, content in ipairs(info.Content) do
        content:SetParent(frame)
        local c_width = CS.Math.round(content:GetWidth())
        local new_x   = x + c_width
        local wrap    = new_x > info.Width
        if wrap then
            x = 0
            y = y - c_height
        end
        content:SetPoint("TOPLEFT", frame, "TOPLEFT", x + offset_x, y + offset_y)
        x = wrap and c_width or new_x
        c_height = CS.Math.round(content:GetHeight())
    end
    register_events(frame, info.Events)
    return frame
end

CS.Interface.Button = function(info)
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
    register_events(button, info.Events)
    return button
end

CS.Interface.StatusBar = function(info)
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
    bar.text:SetTextColor(0.0, 1.0, 0.0)
    register_events(bar, info.Events)
    return bar
end

CS.Interface.Icon = function(info)
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
    register_events(bar, info.Events)
    return icon
end

CS.Interface.Text = function(info)
    local frame = CreateFrame("Frame", info.Global or nil, nil)
    frame:SetSize(info.Width, info.Height)
    frame.text = frame:CreateFontString(nil, "ARTWORK")
    frame.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
    frame.text:SetPoint("CENTER", 0, 0)
    frame.text:SetText(info.Text or "")
    register_events(frame, info.Events)
    return frame
end

CS.Interface.Dropdown = function(info)
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

    register_events(dropdown, info.Events)
    return dropdown
end

CS.Interface.Toggle = function(frame)
    if frame:IsVisible() then
        frame:Hide()
    else
        frame:Show()
    end
end
