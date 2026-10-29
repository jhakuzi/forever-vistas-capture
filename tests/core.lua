-- Run from repository root: lua tests/core.lua
local addon = {}
local frame = { RegisterEvent = function() end, SetScript = function() end }
CreateFrame = function() return frame end
SlashCmdList = {}
assert(loadfile("ForeverVistasCapture/Core.lua"))("ForeverVistasCapture", addon)
local c = {mapID=12, x=12.346, y=67.891, timestamp=1700000000,
    continentID=1, worldX=-123.46, worldY=42.01}
assert(addon.Encode(c) == "FV1:12:12.35:67.89:1700000000:1:-123.5:42.0")
assert(addon.Encode({timestamp=1}) == "FV1:-:-:-:1:-:-:-")
local history = {}
for i = 1, 21 do addon.AddHistory(history, {timestamp=i}) end
assert(#history == 20 and history[1].timestamp == 21 and history[20].timestamp == 2)
local shots, changes, notices = 0, 0, {}
local controller = addon.NewCaptureController(history, function() shots = shots + 1 end,
    function(s) notices[#notices+1] = s end, function() changes = changes + 1 end)
assert(controller.capture(c))
assert(not controller.capture({timestamp=2}) and shots == 1)
controller.event("UNRELATED")
assert(changes == 0)
controller.event("SCREENSHOT_FAILED")
assert(#history == 20 and changes == 0)
assert(controller.capture(c))
controller.event("SCREENSHOT_SUCCEEDED")
assert(history[1] == c and #history == 20 and changes == 1)
controller.event("SCREENSHOT_SUCCEEDED")
assert(changes == 1)
local broken = addon.NewCaptureController({}, function() error("failed") end, function() end, function() end)
assert(not broken.capture(c))
assert(not broken.capture(c))
print("core tests passed")
