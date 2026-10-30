-- Run from repository root: lua tests/core.lua
local addon = {}
local frame = { RegisterEvent = function() end, SetScript = function() end }
CreateFrame = function() return frame end
SlashCmdList = {}

assert(loadfile("ForeverVistasCapture/Core.lua"))("ForeverVistasCapture", addon)

local capture = {mapID = 12, x = 12.346, y = 67.891, zone = "Elwynn Forest"}
assert(addon.Encode(capture) == "FV2:12:12.35:67.89")
assert(addon.Encode({mapID = 12, x = -1, y = 2}) == nil)
assert(addon.Encode({mapID = 0 / 0, x = 1, y = 2}) == nil)

local history = {}
for i = 1, 6 do addon.AddHistory(history, {mapID = i, x = 1, y = 2}) end
assert(#history == 5 and history[1].mapID == 6 and history[5].mapID == 2)

local old = addon.Clean({mapID = 37, x = 44, y = 55, timestamp = 1, worldX = 7})
assert(old and old.mapID == 37 and old.x == 44 and old.y == 55 and old.timestamp == nil)

print("core tests passed")
