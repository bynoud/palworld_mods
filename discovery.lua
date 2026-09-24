--[[
  DISCOVERY SCRIPT v2 — simplified for the text-list UI approach.

  We no longer need native-widget hover events. We only need to find,
  for YOUR game version:
    1. How to get a reference to the Pal you want to extract from
       (this version targets your active "Otomo" partner Pal — the one
       currently following you — since that's reachable without any
       menu being open at all)
    2. The property/function that lists a Pal's current passive skills
    3. The function/way to remove one passive from that list
    4. The function/way to add an item to the player's inventory by
       StaticItemId

  HOW TO USE:
    1. Drop this folder in .../Pal/Binaries/Win64/ue4ss/Mods/
    2. Have a Pal out as your active partner (following you).
    3. Press F9 in-game and read the UE4SS console/log output.
    4. Copy the relevant names into extractor's main.lua TODOs.
]]

local function class_name(obj)
    local ok, name = pcall(function() return obj:GetClassName() end)
    return ok and name or "?"
end

-- Print every property + function on an object whose name contains
-- any of the given keyword fragments (case-insensitive). This is a
-- blunt but effective way to shortlist candidates without needing to
-- already know the exact name.
local function dump_matching(obj, keywords, label)
    if not obj then
        print(label .. ": object not found")
        return
    end
    print(label .. " = " .. class_name(obj))

    local class = obj:GetClass()
    if not class then return end

    local function matches(name)
        name = name:lower()
        for _, kw in ipairs(keywords) do
            if name:find(kw) then return true end
        end
        return false
    end

    -- Properties
    local ok, props = pcall(function() return class:GetProperties() end)
    if ok and props then
        for _, prop in pairs(props) do
            local pname = prop:GetName()
            if matches(pname) then
                print("  [prop]  " .. pname)
            end
        end
    end

    -- Functions
    local ok2, funcs = pcall(function() return class:GetFunctions() end)
    if ok2 and funcs then
        for _, fn in pairs(funcs) do
            local fname = fn:GetName()
            if matches(fname) then
                print("  [func]  " .. fname)
            end
        end
    end
end

RegisterKeyBind(Key.F9, function()
    ExecuteInGameThread(function()
        print("=== [PassiveExtractor Discovery v2] F9 pressed ===")

        local player = FindFirstOf("PalPlayerCharacter")
        print("PalPlayerCharacter found:", player ~= nil)
        if player then
            dump_matching(player, {"otomo", "partner", "party"}, "PalPlayerCharacter (looking for the active Pal reference)")
            dump_matching(player, {"inventory", "item", "additem"}, "PalPlayerCharacter (looking for inventory/add-item)")
        end

        -- If the above surfaces a handle-returning function, call it here
        -- once you know its name, then dump ITS properties/functions too,
        -- e.g.:
        -- local otomo = player:GetOtomoPalHandle()  -- placeholder name
        -- dump_matching(otomo, {"passive", "skill"}, "Otomo Pal handle (looking for passive list)")

        print("=== end scan ===")
    end)
end)

print("[PassiveExtractor Discovery v2] loaded. Have a Pal following you, press F9.")
