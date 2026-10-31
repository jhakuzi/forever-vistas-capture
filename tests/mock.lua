-- Run from repository root with Lua 5.1 or later.
local frames, screenshots = {}, 0
local methods = {}
function methods:SetScript(name, fn) self.scripts[name] = fn end
function methods:RegisterEvent(name) self.events[name] = true end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:SetText(text) self.text = text end
function methods:CreateFontString() return CreateFrame("FontString") end
local noop = function() end
local mt = {__index = function(_, k) return methods[k] or noop end}

function CreateFrame(kind, name, parent, template)
    local frame = setmetatable({scripts = {}, events = {}, kind = kind, template = template}, mt)
    if template == "BasicFrameTemplateWithInset" then frame.TitleText = CreateFrame("FontString") end
    frames[#frames + 1] = frame
    return frame
end

UIParent = CreateFrame("Frame")
SlashCmdList = {}
GetRealZoneText = function() return "Test zone" end
Screenshot = function() screenshots = screenshots + 1 end
C_Map = {
    GetBestMapForUnit = function() return 37 end,
    GetPlayerMapPosition = function()
        return {GetXY = function() return 0.1234, 0.5678 end}
    end,
}

local addon = {}
assert(loadfile("ForeverVistasCapture/Core.lua"))("ForeverVistasCapture", addon)
assert(loadfile("ForeverVistasCapture/UI.lua"))("ForeverVistasCapture", addon)

local eventFrame
for _, frame in ipairs(frames) do
    if frame.events.ADDON_LOADED then eventFrame = frame end
end
ForeverVistasCaptureDB = {history = {"bad", {mapID = 1, x = 2, y = 3, zone = "Old"}}}
eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "ForeverVistasCapture")
assert(#ForeverVistasCaptureDB.history == 1)

SlashCmdList.FOREVERVISTAS("capture")
assert(screenshots == 1 and #ForeverVistasCaptureDB.history == 2)

local row, edit
for _, frame in ipairs(frames) do
    if not row and frame.template == "UIPanelButtonTemplate" then row = frame end
    if frame.kind == "EditBox" then edit = frame end
end
row.scripts.OnClick(row)
assert(edit.text == "FV2:37:12.34:56.78")
ForeverVistasCapture_CompartmentClick()

print("mock client tests passed")
