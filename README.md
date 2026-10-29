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

## Launch-day smoke test

1. Install the clean `ForeverVistasCapture` folder, restart the Forever client, and confirm the addon loads without errors and is enabled. Check the interface number against the launch client.
2. Open `/fv` and the Addon Compartment entry; drag the window, reload, and confirm its position. Assign Capture Vista in Key Bindings.
3. Capture using `/fv capture`, then the binding. Confirm each screenshot is saved and appears once in history; select a row and copy its FV1 code.
4. Try an area without a map position, rapid requests, and a screenshot failure if practical. Confirm missing coordinates show as unavailable and no failed capture enters history. Reload and check persistence.
5. Compare map and world values with the client's map in a known location. Verify timeout and late-event behavior if a result can be delayed safely.

The build 70170 map reference documents the map functions and the Forever API notes report screenshot events; availability of timers, native frame templates, binding XML, automatic compartment registration, and the precise behavior of all these APIs in the launch client remain client verification items. Missing map data is encoded as `-`; malformed saved entries and invalid or non-finite coordinates are discarded. The original valid UI map ID is retained. World coordinates are omitted as a group if invalid; world values outside ±10,000,000 are rejected. Map percentages outside 0–100 are omitted as a pair. Epoch seconds must be an integer from 0 to 2147483647. If the timer or screenshot event registration is unavailable, capture is disabled. If a screenshot call errors after it might have started, the addon waits for a result or reload before accepting another request.

Run both `lua tests/core.lua` and `lua tests/mock.lua` for the core and mocked client tests. These mocks do not verify client APIs. `Bindings.xml` is loaded by the client automatically and is deliberately not listed in the TOC.
