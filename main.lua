--[[
  Pal Passive Extractor — text-list UI version
  ----------------------------------------------
  Press the toggle key to open a numbered on-screen list of your active
  partner Pal's current passives. Press a number key to extract that
  passive: you get a "Disposable Passive Implant" item and the Pal loses
  that passive.

  REQUIRES: UE4SS (Lua scripting enabled) + PalSchema
  Place this whole "PalPassiveExtractor" folder in:
    .../Pal/Binaries/Win64/ue4ss/Mods/

  >>> BEFORE THIS WILL WORK <<<
  Run discovery.lua against YOUR game version first and fill in the
  TODO blocks below (4 of them). Names differ per patch, so they're
  intentionally left as placeholders rather than guesses.
]]

local TOGGLE_KEY = Key.F8
local CANCEL_KEY = Key.Escape
local NUMBER_KEYS = { Key.One, Key.Two, Key.Three, Key.Four, Key.Five, Key.Six } -- verify these exist in the Key table for your UE4SS build; some builds use Key.Zero..Key.Nine

local IMPLANT_ITEM_STATIC_ID = "PassiveExtractor_DisposableImplant" -- must match items.jsonc

local state = {
    open = false,
    pal_handle = nil,
    passives = {},   -- list of { display_name = "...", row_id = "..." }
    loop_handle = nil,
}

--------------------------------------------------------------------------
-- TODO #1: Get the active partner ("Otomo") Pal's handle.
-- discovery.lua's scan of PalPlayerCharacter for "otomo"/"partner"/"party"
-- should surface either a direct property or a getter function.
--------------------------------------------------------------------------
local function get_target_pal_handle()
    local player = FindFirstOf("PalPlayerCharacter")
    if not player then return nil end

    -- Placeholder — replace once you know the real accessor, e.g.:
    -- return player:GetOtomoPalHandle()
    -- or maybe it's an array and you want index 1:
    -- local otomos = player.OtomoPalHandles
    -- return otomos and otomos[1] or nil

    return nil
end

--------------------------------------------------------------------------
-- TODO #2: Read a Pal's current passive list.
-- Should return an array of { display_name, row_id } for each passive
-- currently on the Pal.
--------------------------------------------------------------------------
local function get_passives(pal_handle)
    if not pal_handle then return {} end

    -- Placeholder — replace once known, e.g.:
    -- local list = pal_handle:GetPassiveSkillList()
    -- local out = {}
    -- for i = 1, list:GetLength() do
    --     local row_id = list[i]
    --     out[#out+1] = { display_name = row_id, row_id = row_id } -- swap in a name lookup if you want prettier text
    -- end
    -- return out

    return {}
end

--------------------------------------------------------------------------
-- TODO #3: Remove one passive (by index into the list above) from a Pal.
--------------------------------------------------------------------------
local function remove_passive(pal_handle, index)
    if not pal_handle then return false end

    -- Placeholder — replace once known, e.g.:
    -- local list = pal_handle:GetPassiveSkillList()
    -- list:Remove(index)
    -- pal_handle:MarkPassiveSkillsDirty() -- or whatever refresh/save call is needed

    print("[PassiveExtractor] TODO: remove_passive not implemented yet")
    return false
end

--------------------------------------------------------------------------
-- TODO #4: Grant the implant item to the player's inventory.
--------------------------------------------------------------------------
local function grant_implant_item(passive_row_id)
    local player = FindFirstOf("PalPlayerCharacter")
    if not player then return false end

    -- Placeholder — replace once known, e.g.:
    -- local inv = player:GetInventoryComponent()
    -- inv:AddItemByStaticId(IMPLANT_ITEM_STATIC_ID, 1)

    print(string.format("[PassiveExtractor] TODO: grant_implant_item not implemented yet (passive=%s)", tostring(passive_row_id)))
    return false
end

--------------------------------------------------------------------------
-- On-screen text list
--------------------------------------------------------------------------
local function draw_list()
    local engine = FindFirstOf("Engine")
    if not engine then return end

    local lines = { "=== Passive Extractor ===" }
    if #state.passives == 0 then
        lines[#lines+1] = "No passives found (or TODOs not filled in yet)."
    else
        for i, p in ipairs(state.passives) do
            lines[#lines+1] = string.format("[%d] %s", i, p.display_name)
        end
    end
    lines[#lines+1] = "Press a number to extract, ESC to cancel."

    -- AddOnScreenDebugMessage(key, duration, color, text)
    -- key must be unique per line or later lines will overwrite earlier ones
    for i, line in ipairs(lines) do
        engine:AddOnScreenDebugMessage(1000 + i, 0.3, {R=255,G=255,B=255,A=255}, line)
    end
end

local function close_ui()
    state.open = false
    state.pal_handle = nil
    state.passives = {}
    if state.loop_handle then
        -- stop the LoopAsync draw loop; see UE4SS docs for the exact
        -- stop mechanism your version uses (returning true from the
        -- loop body is one common pattern, used below instead of
        -- storing a handle)
        state.loop_handle = nil
    end
end

local function open_ui()
    local pal = get_target_pal_handle()
    if not pal then
        print("[PassiveExtractor] No active partner Pal found (or TODO #1 not implemented yet).")
        return
    end

    state.pal_handle = pal
    state.passives = get_passives(pal)
    state.open = true

    LoopAsync(300, function()
        if not state.open then
            return true -- returning true stops the loop
        end
        draw_list()
        return false
    end)
end

--------------------------------------------------------------------------
-- Input
--------------------------------------------------------------------------
RegisterKeyBind(TOGGLE_KEY, function()
    ExecuteInGameThread(function()
        if state.open then
            close_ui()
        else
            open_ui()
        end
    end)
end)

RegisterKeyBind(CANCEL_KEY, function()
    if state.open then
        ExecuteInGameThread(function()
            close_ui()
        end)
    end
end)

for index, key in ipairs(NUMBER_KEYS) do
    RegisterKeyBind(key, function()
        if not state.open then return end
        ExecuteInGameThread(function()
            local chosen = state.passives[index]
            if not chosen then
                print(string.format("[PassiveExtractor] No passive at slot %d", index))
                return
            end

            local granted = grant_implant_item(chosen.row_id)
            if not granted then
                print("[PassiveExtractor] Aborting: item grant failed, leaving passive untouched.")
                return
            end

            local removed = remove_passive(state.pal_handle, index)
            if not removed then
                print("[PassiveExtractor] WARNING: item granted but passive removal failed.")
            end

            print(string.format("[PassiveExtractor] Extracted: %s", chosen.display_name))
            close_ui()
        end)
    end)
end

print("[PassiveExtractor] loaded. Press F8 with a partner Pal out to open the extract list (once TODOs are filled in).")
