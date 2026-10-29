local _, addon = ...
BINDING_HEADER_FOREVERVISTAS = "Forever Vistas Capture"
BINDING_NAME_FOREVERVISTAS_CAPTURE = "Capture Vista"

local function number(value, places)
    if value == nil then return "-" end
    return string.format(places == 2 and "%.2f" or "%.1f", value)
end

function addon.Encode(c)
    return table.concat({"FV1", c.mapID and tostring(c.mapID) or "-",
        number(c.x, 2), number(c.y, 2), tostring(c.timestamp),
        c.continentID and tostring(c.continentID) or "-",
        number(c.worldX, 1), number(c.worldY, 1)}, ":")
end

function addon.AddHistory(history, capture)
    table.insert(history, 1, capture)
    while #history > 20 do table.remove(history) end
end

-- Screenshot events carry no request ID. Only one addon request may be pending.
function addon.NewCaptureController(history, takeScreenshot, notify, changed, schedule)
    local pending, expired
    local generation = 0
    return {
        capture = function(capture)
            if expired then
                notify("Screenshot result overdue; wait for it or reload before capturing again.")
                return false
            end
            if pending then
                notify("A screenshot is still pending; please wait.")
                return false
            end
            pending = capture
            generation = generation + 1
            local request = generation
            local ok = pcall(takeScreenshot)
            if not ok then
                pending = nil
                notify("Screenshot request failed.")
                return false
            end
            schedule(15, function()
                if pending and generation == request then
                    pending = nil
                    expired = true
                    notify("Screenshot result timed out; wait for it or reload. No capture saved.")
                end
            end)
            return true
        end,
        event = function(event)
            if expired and (event == "SCREENSHOT_SUCCEEDED" or event == "SCREENSHOT_FAILED") then
                expired = false
                notify("Late screenshot result ignored; capture is available again.")
                return
            end
            if not pending then return end
            if event == "SCREENSHOT_SUCCEEDED" then
                addon.AddHistory(history, pending)
                pending = nil
                notify("Vista captured.")
                changed()
            elseif event == "SCREENSHOT_FAILED" then
                pending = nil
                notify("Screenshot failed; no capture saved.")
            end
        end,
    }
end

local controller
local function message(s) print("|cff66ccffForever Vistas:|r " .. s) end
local function location()
    local c = { timestamp = time(), zone = GetRealZoneText() or "" }
    local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
    if not ok or not mapID then return c end
    c.mapID = mapID
    local got, pos = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
    if not got or not pos then return c end
    local xy, x, y = pcall(pos.GetXY, pos)
    if not xy or type(x) ~= "number" or type(y) ~= "number" then return c end
    c.x, c.y = x * 100, y * 100
    local worldOK, continent, world = pcall(C_Map.GetWorldPosFromMapPos, mapID, pos)
    if worldOK and continent and world then
        local success, wx, wy = pcall(world.GetXY, world)
        if success and type(wx) == "number" and type(wy) == "number" then
            c.continentID, c.worldX, c.worldY = continent, wx, wy
        end
    end
    return c
end

function ForeverVistasCapture_Capture()
    if not controller then message("Addon is not ready yet."); return end
    controller.capture(location())
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
-- Some clients throw for unknown events; leave capture disabled in that case.
local successEvent = pcall(events.RegisterEvent, events, "SCREENSHOT_SUCCEEDED")
local failureEvent = pcall(events.RegisterEvent, events, "SCREENSHOT_FAILED")
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == "ForeverVistasCapture" then
        ForeverVistasCaptureDB = type(ForeverVistasCaptureDB) == "table" and ForeverVistasCaptureDB or {}
        local db = ForeverVistasCaptureDB
        db.history = type(db.history) == "table" and db.history or {}
        while #db.history > 20 do table.remove(db.history) end
        if successEvent and failureEvent and type(Screenshot) == "function" then
            controller = addon.NewCaptureController(db.history, Screenshot, message, function() addon.Refresh() end, C_Timer.After)
        else
            message("Screenshot events unavailable; capture is disabled.")
        end
        addon.InitUI(db)
    elseif controller then
        controller.event(event)
    end
end)
SLASH_FOREVERVISTAS1 = "/fv"
SlashCmdList.FOREVERVISTAS = function(msg)
    if msg:lower():match("^%s*capture%s*$") then
        ForeverVistasCapture_Capture()
    elseif msg:match("^%s*$") then
        addon.Toggle()
    else
        message("Use /fv or /fv capture.")
    end
end
