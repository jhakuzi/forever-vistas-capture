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
local timers = {}
local function schedule(_, fn) timers[#timers+1] = fn end
local controller = addon.NewCaptureController(history, function() shots = shots + 1 end,
    function(s) notices[#notices+1] = s end, function() changes = changes + 1 end, schedule)
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
local broken = addon.NewCaptureController({}, function() error("failed") end, function() end, function() end, schedule)
assert(not broken.capture(c))
assert(not broken.capture(c))
assert(controller.capture({timestamp=3}))
timers[#timers]()
assert(not controller.capture(c))
controller.event("SCREENSHOT_SUCCEEDED")
assert(history[1] == c and changes == 1)
assert(controller.capture(c))
controller.event("SCREENSHOT_FAILED")
local bad = addon.Clean({timestamp=1, mapID=0/0, x=math.huge, y=1, continentID=1, worldX=0/0, worldY=1})
assert(addon.Encode(bad) == "FV1:-:-:-:1:-:-:-")
assert(addon.Clean({timestamp=math.huge}) == nil)
assert(addon.Encode({timestamp=1, mapID=12, x=-1, y=2}) == "FV1:12:-:-:1:-:-:-")
local failTimer = addon.NewCaptureController({}, function() error("must not shoot") end, function() end, function() end, function() error("timer") end)
assert(not failTimer.capture(c))
local late = addon.NewCaptureController({}, function() error("screenshot") end, function() end, function() end, schedule)
assert(not late.capture(c))
assert(not late.capture(c))
late.event("SCREENSHOT_FAILED")
assert(not late.capture(c)) -- screenshot still throws, but was accepted again
print("core tests passed")
