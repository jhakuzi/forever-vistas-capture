# Forever Vistas Capture

A small WoW: Forever addon that takes a screenshot and remembers the zone-map position for [Forever Vistas](https://forevervistas.org).

## Install and Use

Copy the **ForeverVistasCapture** folder into the game's **Interface/AddOns** folder, then type **/reload** in-game. You're good to go.

- **/fv capture** takes a normal screenshot and saves the best available location as a recent capture. In a dungeon or raid it records the instance name; if location data is unavailable it still takes the screenshot.
- **/fv** or the **Addon Compartment** entry opens your five most recent captures. Select one and press **Ctrl+C** in the highlighted field to copy its capture code.
- In **Key Bindings**, assign **Capture Vista** under **Forever Vistas Capture**. There is no default shortcut, and the normal screenshot key is not used by the addon.
- After a capture's screenshot completes, a small box opens with the capture code selected; press **Ctrl+C** to copy it and **Escape** to close the box.

## Capture Code Format

**FV2:mapID:x:y** for mapped outdoor zones. Dungeon and raid captures use **FV3:DUNGEON:name** and **FV3:RAID:name**, where the name is URL-encoded UTF-8. Captures without usable location data use **FV3:UNKNOWN:name**; the name can be empty.

**mapID** is the numeric UI map ID for the zone. The Forever Vistas website uses it to identify the correct illustrated zone map.

**x** and **y** are in-game map coordinates.

If the client returns a continent instead of a zone, the addon requires a unique child map matching the game's current zone name and reads coordinates on that zone map. If it cannot establish a zone and position, it still takes the screenshot and saves an unknown-location code. Dungeon/raid screenshots use their instance name and do not require a continent or zone map. Continent coordinates from older capture codes cannot be converted by the website.

**Examples:** **FV2:1429:12.34:56.78** (Elwynn Forest), **FV3:DUNGEON:The%20Deadmines**

The capture list displays the game's zone or instance name to help you identify each screenshot. FV2 codes use numeric map IDs because these are independent of the game's language settings.
