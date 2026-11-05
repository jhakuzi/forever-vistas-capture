-- Run from repository root with Lua 5.1 or later.
local frames, screenshots = {}, 0
local timers = {}
C_Timer = { After = function(seconds, callback) assert(seconds == 5); timers[#timers + 1] = callback end }
local methods = {}
function methods:SetScript(name, fn) self.scripts[name] = fn end
function methods:RegisterEvent(name) self.events[name] = true end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:SetText(text) self.text = text end
function methods:SetFocus() self.focused = true end
function methods:HighlightText() self.highlighted = true end
function methods:CreateFontString() return CreateFrame("FontString", nil, self) end
local noop = function() end
local mt = {__index = function(_, k) return methods[k] or noop end}

function CreateFrame(kind, name, parent, template)
    local frame = setmetatable({scripts = {}, events = {}, kind = kind, name = name, parent = parent, template = template}, mt)
    if template == "BasicFrameTemplateWithInset" then frame.TitleText = CreateFrame("FontString") end
    frames[#frames + 1] = frame
    return frame
end

UIParent = CreateFrame("Frame")
SlashCmdList = {}
GetRealZoneText = function() return "Test zone" end
Screenshot = function() screenshots = screenshots + 1 end
time = function() return 1700000000 end
date = function(format, timestamp)
    assert(format == "%x %H:%M" and timestamp == 1700000000)
    return "11/14/23 22:13"
end
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
for _, frame in ipairs(frames) do assert(frame.name ~= "ForeverVistasCaptureWelcome") end
local oldRow
for _, frame in ipairs(frames) do
    if frame.template == "UIPanelButtonTemplate" then oldRow = frame; break end
end
assert(oldRow.text == "Old  |  2.00, 3.00")

SlashCmdList.FOREVERVISTAS("capture")
assert(screenshots == 1 and #ForeverVistasCaptureDB.history == 2)
assert(ForeverVistasCaptureDB.history[1].timestamp == 1700000000)
assert(oldRow.text == "Test zone  |  12.34, 56.78  |  11/14/23 22:13")

local row, edit
local mainWindow, copyWindow, copyEdit
for _, frame in ipairs(frames) do
    if not row and frame.template == "UIPanelButtonTemplate" then row = frame end
    if frame.name == "ForeverVistasCaptureWindow" then mainWindow = frame end
    if frame.name == "ForeverVistasCaptureCopyWindow" then copyWindow = frame end
    if frame.kind == "EditBox" and frame.parent == mainWindow then edit = frame end
    if frame.kind == "EditBox" and frame.parent == copyWindow then copyEdit = frame end
end
assert(not mainWindow.shown and not copyWindow.shown)
ForeverVistasCapture_Capture()
assert(screenshots == 1 and not copyWindow.shown)
eventFrame.scripts.OnEvent(eventFrame, "SCREENSHOT_SUCCEEDED")
assert(copyWindow.shown and copyEdit.text == "FV2:37:12.34:56.78")
assert(copyEdit.focused and copyEdit.highlighted and not mainWindow.shown)
row.scripts.OnClick(row)
assert(edit.text == "FV2:37:12.34:56.78")
Screenshot = function()
    assert(not copyWindow.shown)
    screenshots = screenshots + 1
end
ForeverVistasCapture_Capture()
assert(screenshots == 2 and ForeverVistasCaptureDB.history[1].timestamp == 1700000000)
assert(not copyWindow.shown and not mainWindow.shown)
eventFrame.scripts.OnEvent(eventFrame, "SCREENSHOT_SUCCEEDED")
assert(copyWindow.shown and not mainWindow.shown)
timers[1]() -- An old timeout must not clear a newer capture or close its popup.
assert(copyEdit.text == "FV2:37:12.34:56.78" and copyEdit.focused and copyEdit.highlighted)
copyEdit.scripts.OnEscapePressed()
assert(not copyWindow.shown)
Screenshot = function() error("failed") end
ForeverVistasCapture_Capture()
assert(not copyWindow.shown and #ForeverVistasCaptureDB.history == 3)
Screenshot = function() screenshots = screenshots + 1 end
SlashCmdList.FOREVERVISTAS("capture")
eventFrame.scripts.OnEvent(eventFrame, "SCREENSHOT_FAILED")
assert(not copyWindow.shown and #ForeverVistasCaptureDB.history == 4)
eventFrame.scripts.OnEvent(eventFrame, "SCREENSHOT_SUCCEEDED")
assert(not copyWindow.shown)
SlashCmdList.FOREVERVISTAS("capture")
local timedOut = timers[#timers]
timers[2]() -- A stale callback cannot clear the pending capture.
ForeverVistasCapture_Capture()
assert(screenshots == 4)
timedOut()
ForeverVistasCapture_Capture()
assert(screenshots == 5 and not copyWindow.shown)
eventFrame.scripts.OnEvent(eventFrame, "SCREENSHOT_SUCCEEDED")
eventFrame.scripts.OnEvent(eventFrame, "SCREENSHOT_SUCCEEDED")
assert(not copyWindow.shown)
eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "ForeverVistasCapture")
assert(ForeverVistasCaptureDB.history[1].timestamp == 1700000000)
ForeverVistasCapture_CompartmentClick()

ForeverVistasCaptureDB = nil
eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "ForeverVistasCapture")
local welcome, dismiss, instructions
for _, frame in ipairs(frames) do
    if frame.name == "ForeverVistasCaptureWelcome" then welcome = frame end
    if welcome and frame.parent == welcome and frame.text == "Got it" then dismiss = frame end
    if welcome and frame.parent == welcome and frame.kind == "FontString" then instructions = frame end
end
assert(welcome and welcome.shown and dismiss and instructions)
assert(instructions.text:find("/fv capture", 1, true) and instructions.text:find("forevervistas.org", 1, true))
dismiss.scripts.OnClick()
assert(not welcome.shown)
local frameCount = #frames
eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "ForeverVistasCapture")
for i = frameCount + 1, #frames do assert(frames[i].name ~= "ForeverVistasCaptureWelcome") end

print("mock client tests passed")
