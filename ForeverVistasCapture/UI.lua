local _, addon = ...
local window, edit, rows, db, copyWindow, copyEdit

function addon.Refresh()
    if not rows then return end
    for i, row in ipairs(rows) do
        local capture = db.history[i]
        if capture then
            local zone = capture.zone ~= "" and capture.zone or "Unknown zone"
            local text = string.format("%s  |  %.2f, %.2f", zone, capture.x, capture.y)
            if capture.timestamp then
                local ok, timestamp = pcall(date, "%x %H:%M", capture.timestamp)
                if ok and timestamp then text = text .. "  |  " .. timestamp end
            end
            row:SetText(text)
            row:Show()
        else
            row:Hide()
        end
    end
end

function addon.InitUI(saved)
    db = saved
    window = CreateFrame("Frame", "ForeverVistasCaptureWindow", UIParent, "BasicFrameTemplateWithInset")
    window:SetSize(560, 220)
    window:SetPoint("CENTER")
    window.TitleText:SetText("Forever Vistas Capture")

    rows = {}
    for i = 1, 5 do
        local index = i
        local row = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
        row:SetSize(520, 22)
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

    copyWindow = CreateFrame("Frame", "ForeverVistasCaptureCopyWindow", UIParent, "BasicFrameTemplateWithInset")
    copyWindow:SetSize(420, 110)
    copyWindow:SetPoint("CENTER")
    copyWindow.TitleText:SetText("Copy capture code")

    local copyLabel = copyWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    copyLabel:SetPoint("TOPLEFT", 20, -35)
    copyLabel:SetText("Press Ctrl+C to copy:")

    copyEdit = CreateFrame("EditBox", nil, copyWindow, "InputBoxTemplate")
    copyEdit:SetSize(380, 24)
    copyEdit:SetPoint("BOTTOMLEFT", 20, 17)
    copyEdit:SetAutoFocus(false)
    copyEdit:SetScript("OnEscapePressed", function() copyWindow:Hide() end)
    copyWindow:Hide()

    addon.Refresh()
    window:Hide()
end

function addon.ShowCopy(capture)
    if not copyWindow then return end
    copyEdit:SetText(addon.Encode(capture))
    copyWindow:Show()
    copyEdit:SetFocus()
    copyEdit:HighlightText()
end

function addon.Toggle()
    if not window then return end
    if window:IsShown() then window:Hide() else addon.Refresh(); window:Show() end
end

function ForeverVistasCapture_CompartmentClick()
    addon.Toggle()
end
