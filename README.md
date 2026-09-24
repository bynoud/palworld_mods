# Pal Passive Extractor — text-list UI version

## What this is
UE4SS + PalSchema mod: press F8 while a Pal is out as your active partner,
get a numbered on-screen list of its current passives, press a number to
extract one. You get a "Disposable Passive Implant" item and the Pal loses
that passive. Press ESC to cancel.

This version deliberately avoids hooking into Palworld's native UI at all —
no widget classes, no hover events. The "UI" is just on-screen debug text
plus number-key input, which only needs two real UE4SS Lua features:
`AddOnScreenDebugMessage` (draws text) and `RegisterKeyBind` (reads keys).

## What's solid vs. what you need to fill in
Solid / documented UE4SS Lua APIs used as-is:
- `RegisterKeyBind`, `ExecuteInGameThread`, `FindFirstOf`, `LoopAsync`,
  `AddOnScreenDebugMessage`

Left as `TODO` placeholders (4 total) because these are Palworld-internal
names that shift between patches and I can't verify live game internals
from here:
1. **Get the active partner Pal's handle** — from `PalPlayerCharacter`.
2. **Read a Pal's current passive list** — array of passive row IDs/names.
3. **Remove one passive from that list.**
4. **Grant the implant item** to the player's inventory by StaticItemId.

`discovery.lua` is built to surface all four by scanning `PalPlayerCharacter`
(and whatever Pal-handle class it points you to) for properties/functions
matching keywords like "otomo", "passive", "inventory".

## Setup
1. Install **UE4SS** (Lua-scripting-enabled build) and **PalSchema**.
2. Put `items.jsonc` where PalSchema expects item definitions for your
   PalSchema version (check its current docs/example mods for the path).
3. Copy `Scripts/discovery.lua` into a UE4SS mod folder, launch the game,
   have a Pal out as your partner, press **F9**, read the console output.
4. Fill the 4 TODOs in `Scripts/main.lua` using those results.
5. Drop the finished `main.lua` into your mod's `Scripts/` folder (remove
   `discovery.lua` or its F9 bind first) and launch.

## Notes / things to double check for your UE4SS build
- `NUMBER_KEYS` uses `Key.One` .. `Key.Six` — some UE4SS builds name these
  differently (e.g. `Key.Zero`..`Key.Nine`, or numpad-specific names).
  Print `Key` in the console once to confirm if binds silently no-op.
- The `LoopAsync` stop convention (returning `true` from the callback)
  matches the commonly documented pattern, but confirm against UE4SS's
  Lua API docs for your exact version if the on-screen text doesn't clear
  when you close the list.
- `AddOnScreenDebugMessage`'s color parameter format has varied slightly
  across UE4SS versions (struct table vs. positional args) — adjust if it
  errors on load.

## Scope note
This targets your **active partner Pal only** (the one following you), not
Pals sitting at a base. That's the deliberate simplification for a v1 —
extending it to base Pals would mean adding a way to pick which base Pal
(e.g. reusing the base Pal list UI or walking a base's Pal array), which is
a reasonable second step once the core extract/remove/grant loop is
confirmed working on the partner Pal case.

## Shortcut worth considering
The existing Nexus mod "Passive Skill Surgery (with passive removal)"
already does extract + remove (via an Operating Table UI). If you can look
at its source, it likely has confirmed working calls for TODOs #2–#4 —
only #1 (partner-Pal lookup) might differ since it works from a table UI
rather than the active partner Pal.
