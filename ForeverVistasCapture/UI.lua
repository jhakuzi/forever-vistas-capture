local _, addon = ...
local window, edit, rows, db

function addon.Refresh()
    if not window then return end
    for i, row in ipairs(rows) do
        local c = db.history[i]
        if c then
            local coords = c.x and c.y and string.format("%.2f, %.2f", c.x, c.y) or "coordinates unavailable"
            row:SetText(string.format("%s  |  %s  |  %s", c.zone ~= "" and c.zone or "Unknown zone", coords, date("%Y-%m-%d %H:%M", c.timestamp)))
            row:Show()
        else
            row:Hide()
        end
    end
end

function addon.InitUI(saved)
    db = saved
    window = CreateFrame("Frame", "ForeverVistasCaptureWindow", UIParent, "BasicFrameTemplateWithInset")
    window:SetSize(440, 370)
    window:SetPoint("CENTER", UIParent, "CENTER", saved.x or 0, saved.y or 0)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        local ux, uy = UIParent:GetCenter()
        if x and y and ux and uy then db.x, db.y = x - ux, y - uy end
    end)
    window:SetClampedToScreen(true)
    window.TitleText:SetText("Forever Vistas Capture")
    local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 14, -35)
    scroll:SetPoint("BOTTOMRIGHT", -32, 68)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(390, 20 * 24)
    scroll:SetScrollChild(content)
    rows = {}
    for i = 1, 20 do
        local index = i
        local row = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        row:SetSize(390, 22)
        row:SetPoint("TOPLEFT", 0, -(i - 1) * 24)
        row:SetScript("OnClick", function()
            local c = db.history[index]
            if c then edit:SetText(addon.Encode(c)); edit:SetFocus(); edit:HighlightText() end
        end)
        rows[i] = row
    end
    local label = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOMLEFT", 18, 47)
    label:SetText("Select a capture, then press Ctrl+C:")
    edit = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    edit:SetSize(390, 24)
    edit:SetPoint("BOTTOMLEFT", 20, 17)
    edit:SetAutoFocus(false)
    edit:SetScript("OnEscapePressed", edit.ClearFocus)
    addon.Refresh()
    window:Hide()
end

function addon.Toggle()
    if not window then return end
    if window:IsShown() then window:Hide() else addon.Refresh(); window:Show() end
end

function ForeverVistasCapture_CompartmentClick() addon.Toggle() end
