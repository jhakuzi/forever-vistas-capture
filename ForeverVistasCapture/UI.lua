local _, addon = ...
local window, edit, rows, db

function addon.Refresh()
    if not rows then return end
    for i, row in ipairs(rows) do
        local capture = db.history[i]
        if capture then
            local zone = capture.zone ~= "" and capture.zone or "Unknown zone"
            row:SetText(string.format("%s  |  %.2f, %.2f", zone, capture.x, capture.y))
            row:Show()
        else
            row:Hide()
        end
    end
end

function addon.InitUI(saved)
    db = saved
    window = CreateFrame("Frame", "ForeverVistasCaptureWindow", UIParent, "BasicFrameTemplateWithInset")
    window:SetSize(420, 220)
    window:SetPoint("CENTER")
    window.TitleText:SetText("Forever Vistas Capture")

    rows = {}
    for i = 1, 5 do
        local index = i
        local row = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
        row:SetSize(380, 22)
        row:SetPoint("TOPLEFT", 20, -35 - (i - 1) * 25)
        row:SetScript("OnClick", function()
            local capture = db.history[index]
            if capture then
                edit:SetText(addon.Encode(capture))
                edit:SetFocus()
                edit:HighlightText()
            end
        end)
        rows[i] = row
    end

    local label = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOMLEFT", 20, 47)
    label:SetText("Select a capture, then press Ctrl+C:")

    edit = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    edit:SetSize(380, 24)
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

function ForeverVistasCapture_CompartmentClick()
    addon.Toggle()
end
