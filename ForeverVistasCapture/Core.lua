local _, addon = ...
BINDING_HEADER_FOREVERVISTAS = "Forever Vistas Capture"
BINDING_NAME_FOREVERVISTAS_CAPTURE = "Capture Vista"

local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
local function id(n)
    return finite(n) and n >= 0 and n <= 2147483647 and n == math.floor(n)
end
function addon.Clean(c)
    if type(c) ~= "table" or not finite(c.timestamp) or c.timestamp < 0 or c.timestamp > 2147483647 or c.timestamp ~= math.floor(c.timestamp) then return nil end
    local out = {timestamp = c.timestamp, zone = type(c.zone) == "string" and c.zone:sub(1, 120) or ""}
    if id(c.mapID) then out.mapID = c.mapID end
    if out.mapID and finite(c.x) and finite(c.y) and c.x >= 0 and c.x <= 100 and c.y >= 0 and c.y <= 100 then out.x, out.y = c.x, c.y end
    if id(c.continentID) and finite(c.worldX) and finite(c.worldY) and math.abs(c.worldX) <= 10000000 and math.abs(c.worldY) <= 10000000 then
        out.continentID, out.worldX, out.worldY = c.continentID, c.worldX, c.worldY
    end
    return out
end
local function number(value, places)
    if value == nil then return "-" end
    return string.format(places == 2 and "%.2f" or "%.1f", value)
end
function addon.Encode(c)
    c = addon.Clean(c)
    if not c then return nil end
    return table.concat({"FV1", c.mapID and string.format("%.0f", c.mapID) or "-",
        number(c.x, 2), number(c.y, 2), string.format("%.0f", c.timestamp),
        c.continentID and string.format("%.0f", c.continentID) or "-",
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
            local scheduled = pcall(schedule, 15, function()
                if pending and generation == request then
                    pending = nil
                    expired = true
                    notify("Screenshot result timed out; wait for it or reload. No capture saved.")
                end
            end)
            if not scheduled then
                pending = nil
                notify("Screenshot timer unavailable; capture cancelled.")
                return false
            end
            local ok = pcall(takeScreenshot)
            if not ok then
                if pending and generation == request then pending = nil; expired = true end
                notify("Screenshot request errored; wait for a result or reload.")
                return false
            end
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
    local c = { timestamp = type(time) == "function" and time() or nil }
    if type(GetRealZoneText) == "function" then
        local ok, zone = pcall(GetRealZoneText)
        if ok then c.zone = zone end
    end
    if type(C_Map) == "table" and type(C_Map.GetBestMapForUnit) == "function" then
        local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
        if ok and id(mapID) then
            c.mapID = mapID
            if type(C_Map.GetPlayerMapPosition) == "function" then
                local got, pos = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
                if got and pos then
                    local xy, x, y = pcall(function() return pos:GetXY() end)
                    if xy and finite(x) and finite(y) then c.x, c.y = x * 100, y * 100 end
                    if type(C_Map.GetWorldPosFromMapPos) == "function" then
                        local worldOK, continent, world = pcall(C_Map.GetWorldPosFromMapPos, mapID, pos)
                        if worldOK and world then
                            local success, wx, wy = pcall(function() return world:GetXY() end)
                            if success then c.continentID, c.worldX, c.worldY = continent, wx, wy end
                        end
                    end
                end
            end
        end
    end
    return addon.Clean(c)
end

function ForeverVistasCapture_Capture()
    if not controller then message("Addon is not ready yet."); return end
    local ok, c = pcall(location)
    if not ok or not c then message("Location timestamp unavailable; capture cancelled."); return end
    controller.capture(c)
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
        local history = {}
        if type(db.history) == "table" then
            for i = 1, math.min(#db.history, 20) do
                local c = addon.Clean(db.history[i])
                if c then history[#history + 1] = c end
            end
        end
        db.history = history
        if not finite(db.x) or math.abs(db.x) > 10000 then db.x = nil end
        if not finite(db.y) or math.abs(db.y) > 10000 then db.y = nil end
        if successEvent and failureEvent and type(Screenshot) == "function" and type(C_Timer) == "table" and type(C_Timer.After) == "function" then
            controller = addon.NewCaptureController(db.history, Screenshot, message, function() addon.Refresh() end, C_Timer.After)
        else
            message("Screenshot events unavailable; capture is disabled.")
        end
        local ok = pcall(addon.InitUI, db)
        if not ok then message("History window unavailable on this client.") end
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
