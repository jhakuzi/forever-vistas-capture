# Forever Vistas Capture

A small WoW: Forever addon for capturing a screenshot and copying its location code for [Forever Vistas](https://forevervistas.org). It does not upload anything.

## Install and use

Copy the `ForeverVistasCapture` folder into the Forever client's `Interface/AddOns` folder, then restart the client and enable the addon. The folder and TOC must both be named `ForeverVistasCapture`. The exact game directory may vary by client installation.

- `/fv capture` records the location immediately before requesting a screenshot. Only successful screenshots enter the latest 20 captures, saved per account.
- `/fv` or the Forever Vistas Capture Addon Compartment entry toggles the history window. Select a row and press Ctrl+C in the highlighted code field. Drag the title bar to move the window.
- In Key Bindings, assign **Capture Vista** under **Forever Vistas Capture**. There is no default shortcut. The normal screenshot key is not intercepted.

One request can be pending at a time. Further requests are rejected until a success or failure event arrives. After 15 seconds without a result, the request expires without saving. Further captures remain blocked until the late result is ignored or `/reload` clears the state; this prevents a late event from confirming a newer request. Screenshot events have no request identifier: a screenshot from another source while an addon capture is pending could be mistaken for its result. Avoid other screenshots until the confirmation message appears.

## FV1 format

`FV1:mapID:x:y:timestamp:continentID:worldX:worldY`

Fields are ASCII, colon-separated decimal values; `-` means unavailable. `mapID` is the numeric UI map ID, not the localized zone name. `x` and `y` are map percentages rounded to two decimal places (0–100 for an in-bounds position). `timestamp` is Unix epoch seconds from the client clock. `continentID` is the numeric ID returned by `C_Map.GetWorldPosFromMapPos`; world X and Y are its vector coordinates, rounded to one decimal place. The three world fields are all `-` if unavailable. The map ID or zone coordinates may also be unavailable. Negative world values retain their sign. No screenshot filename or zone name is encoded. Example: `FV1:12:12.35:67.89:1700000000:1:-123.5:42.0`.

## Compatibility and checks

The TOC targets Forever build 70170's interface `16001`. The [client-generated C_Map reference](https://github.com/Atraeau/WoW-Addons/blob/main/docs/api/Map-Instances-World/C_Map.md) documents the map and world-position calls. [Forever API notes](https://github.com/xIGBClutchIx/ForeverPlusPlus/blob/main/docs/forever-api.md) describe screenshot events and the map conversion, but do not verify this addon. The compartment uses the native TOC registration convention.

**Not verified in the Forever client:** addon loading and TOC version on current builds; screenshot event delivery, timing and failure cases; map availability and world-coordinate correctness; binding and compartment registration; window rendering, copy selection, positioning and SavedVariables persistence. Test these in the actual client, including missing map coordinates and rapid requests. Changes to the client may require a TOC update.

Run `lua tests/core.lua` from the repository root with a Lua interpreter to exercise encoding, bounded history and screenshot event handling. This does not substitute for client testing.
