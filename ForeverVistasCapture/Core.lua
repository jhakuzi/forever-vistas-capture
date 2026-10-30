local _, addon = ...
BINDING_HEADER_FOREVERVISTAS = "Forever Vistas Capture"
BINDING_NAME_FOREVERVISTAS_CAPTURE = "Capture Vista"

local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

local function mapID(n)
    return finite(n) and n >= 0 and n <= 2147483647 and n == math.floor(n)
end

function addon.Clean(c)
    if type(c) ~= "table" or not mapID(c.mapID) then return nil end
    if not finite(c.x) or not finite(c.y) or c.x < 0 or c.x > 100 or c.y < 0 or c.y > 100 then return nil end
    return {
        mapID = c.mapID,
        x = c.x,
        y = c.y,
        zone = type(c.zone) == "string" and c.zone:sub(1, 120) or "",
    }
end

-- The numeric UI map ID identifies the zone. The site resolves it to its zone map.
function addon.Encode(c)
    c = addon.Clean(c)
    if not c then return nil end
    return string.format("FV2:%d:%.2f:%.2f", c.mapID, c.x, c.y)
end

function addon.AddHistory(history, capture)
    table.insert(history, 1, capture)
    while #history > 5 do table.remove(history) end
end

local function message(s)
    print("|cff66ccffForever Vistas:|r " .. s)
end

local function location()
    if type(C_Map) ~= "table" or type(C_Map.GetBestMapForUnit) ~= "function" or type(C_Map.GetPlayerMapPosition) ~= "function" then
        return nil
    end

    local ok, id = pcall(C_Map.GetBestMapForUnit, "player")
    if not ok or not mapID(id) then return nil end

    local got, position = pcall(C_Map.GetPlayerMapPosition, id, "player")
    if not got or not position then return nil end

    local haveXY, x, y = pcall(function() return position:GetXY() end)
    if not haveXY then return nil end

    local zone = ""
    if type(GetRealZoneText) == "function" then
        local haveZone, name = pcall(GetRealZoneText)
        if haveZone then zone = name end
    end

    return addon.Clean({mapID = id, x = x * 100, y = y * 100, zone = zone})
end

function ForeverVistasCapture_Capture()
    if type(Screenshot) ~= "function" then
        message("Screenshot support is unavailable.")
        return
    end

    local ok, capture = pcall(location)
    if not ok or not capture then
        message("Current zone or map coordinates are unavailable; nothing was saved.")
        return
    end

    local tookScreenshot = pcall(Screenshot)
    if not tookScreenshot then
        message("Screenshot request failed; location was not saved.")
        return
    end

    addon.AddHistory(ForeverVistasCaptureDB.history, capture)
    addon.Refresh()
    message("Vista captured.")
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, event, name)
    if event ~= "ADDON_LOADED" or name ~= "ForeverVistasCapture" then return end

    ForeverVistasCaptureDB = type(ForeverVistasCaptureDB) == "table" and ForeverVistasCaptureDB or {}
    local history = {}
    if type(ForeverVistasCaptureDB.history) == "table" then
        for i = 1, math.min(#ForeverVistasCaptureDB.history, 5) do
            local capture = addon.Clean(ForeverVistasCaptureDB.history[i])
            if capture then history[#history + 1] = capture end
        end
    end
    ForeverVistasCaptureDB.history = history

    local ok = pcall(addon.InitUI, ForeverVistasCaptureDB)
    if not ok then message("Capture window is unavailable on this client.") end
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
