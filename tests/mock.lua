-- Run from repository root with Lua 5.1 or later.
local frames, timers, screenshots = {}, {}, 0
local methods = {}
function methods:SetScript(name, fn) self.scripts[name] = fn end
function methods:RegisterEvent(name) self.events[name] = true end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:SetText(text) self.text = text end
function methods:GetCenter() return 100, 100 end
function methods:CreateFontString() return CreateFrame("FontString") end
local noop = function() end
local mt = {__index = function(_, k) return methods[k] or noop end}
function CreateFrame(kind, name, parent, template)
    local f = setmetatable({scripts={}, events={}, kind=kind, template=template}, mt)
    if template == "BasicFrameTemplateWithInset" then f.TitleText = CreateFrame("FontString") end
    frames[#frames+1] = f
    return f
end
UIParent = CreateFrame("Frame")
SlashCmdList = {}
time = function() return 1700000000 end
date = function() return "date" end
GetRealZoneText = function() return "Test zone" end
Screenshot = function() screenshots = screenshots + 1 end
C_Timer = {After = function(_, fn) timers[#timers+1] = fn end}
local addon = {}
assert(loadfile("ForeverVistasCapture/Core.lua"))("ForeverVistasCapture", addon)
assert(loadfile("ForeverVistasCapture/UI.lua"))("ForeverVistasCapture", addon)
local eventFrame = frames[2]
ForeverVistasCaptureDB = {history = {"bad", {timestamp=1, zone={}, x=0/0}}, x=math.huge}
eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "ForeverVistasCapture")
assert(#ForeverVistasCaptureDB.history == 1 and ForeverVistasCaptureDB.x == nil)
SlashCmdList.FOREVERVISTAS("")
assert(ForeverVistasCaptureWindow == nil) -- mock does not register named globals
SlashCmdList.FOREVERVISTAS("capture")
assert(screenshots == 1)
ForeverVistasCapture_Capture()
assert(screenshots == 1)
eventFrame.scripts.OnEvent(eventFrame, "SCREENSHOT_SUCCEEDED")
assert(#ForeverVistasCaptureDB.history == 2)
local row, edit
for _, f in ipairs(frames) do
    if not row and f.template == "UIPanelButtonTemplate" then row = f end
    if f.kind == "EditBox" then edit = f end
end
row.scripts.OnClick(row)
assert(edit.text == "FV1:-:-:-:1700000000:-:-:-")
ForeverVistasCapture_CompartmentClick()
print("mock client tests passed")
