# Forever Vistas Capture

A small WoW: Forever addon that takes a screenshot and remembers the zone-map position for [Forever Vistas](https://forevervistas.org). It does not upload or rename screenshots.

## Install and use

Copy the \`ForeverVistasCapture\` folder into the Forever client's \`Interface/AddOns\` folder, restart the client, then enable the addon. The folder and TOC must both be named \`ForeverVistasCapture\`. Only that folder is the addon. The \`tests\` directory is not part of it, and GitHub's source download leaves it out.

- \`/fv capture\` reads your current zone map and coordinates, requests a normal screenshot, then saves the location as a recent capture.
- \`/fv\` or the Addon Compartment entry opens the five most recent captures. Select one and press Ctrl+C in the highlighted field.
- In Key Bindings, assign **Capture Vista** under **Forever Vistas Capture**. There is no default shortcut and the normal screenshot key is not intercepted.

The addon records the location before requesting the screenshot, so it matches where your character was standing when you pressed the keybind. It does not wait for screenshot events: they do not identify the corresponding screenshot and can therefore not reliably link a result to a request.

## FV2 format

\`FV2:mapID:x:y\`

\`mapID\` is the numeric UI map ID for the zone. The Forever Vistas website resolves it to the correct illustrated zone map. \`x\` and \`y\` are in-game map percentages, rounded to two decimal places. Example: \`FV2:1429:12.34:56.78\` for Elwynn Forest.

The display list includes the client's zone name only to help you choose the capture. The transmitted string deliberately uses \`mapID\`, because it is stable across game languages and unambiguous to the website.

## Compatibility and checks

The TOC targets Forever build 70170's interface \`16001\`. The [client-generated C_Map reference](https://github.com/Atraeau/WoW-Addons/blob/main/docs/api/Map-Instances-World/C_Map.md) documents the map calls used here. Verify addon loading, current map availability, key binding, screenshot request, and copy selection in the actual Forever client.

Clone the repository and run both \`lua tests/core.lua\` and \`lua tests/mock.lua\` from the repository root for the encoding and mocked-client checks. Those scripts are not included in the source download, and they do not verify the real game APIs.
