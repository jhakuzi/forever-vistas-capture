# Forever Vistas Capture

A small WoW: Forever addon that takes a screenshot and remembers the zone-map position for [Forever Vistas](https://forevervistas.org).

## Install and use

Copy the \`ForeverVistasCapture\` folder into the Forever game's \`Interface/AddOns\` folder, then do a quick /reload an you're good to go.

- \`/fv capture\` reads your current zone map and coordinates, takes a normal screenshot, then saves the location as a recent capture.
- \`/fv\` or the Addon Compartment entry opens the five most recent captures. Select one and press Ctrl+C in the highlighted field.
- In Key Bindings, assign **Capture Vista** under **Forever Vistas Capture**. There is no default shortcut and the normal screenshot key is not used by the Addon.


## Format

\`FV2:mapID:x:y\`

\`mapID\` is the numeric UI map ID for the zone. The Forever Vistas website resolves it to the correct illustrated zone map. \`x\` and \`y\` are in-game map coordinates. Example: \`FV2:1429:12.34:56.78\` for Elwynn Forest.

The display list includes the games's zone name only to help you choose the capture. The transmitted string deliberately uses \`mapID\`, because it is stable across game languages etc.
