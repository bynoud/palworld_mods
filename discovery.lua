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

-- Live-test version: instead of hand-tracing the object dump, just call
-- the candidate function and ask the result what it actually is via
-- GetFullName() (a confirmed-real UE4SS Lua method).
RegisterKeyBind(Key.F9, function()
    ExecuteInGameThread(function()
        print("=== [PassiveExtractor Discovery v3 - live test] F9 pressed ===")

        local holder = FindFirstOf("PalPlayerPartyPalHolder")
        if not holder then
            print("PalPlayerPartyPalHolder: NOT FOUND via FindFirstOf")
            return
        end
        print("Holder found: " .. holder:GetFullName())

        local ok, pal = pcall(function() return holder:GetOtomoPal(false) end)
        if not ok then
            print("GetOtomoPal(false) call FAILED — error: " .. tostring(pal))
            return
        end
        if not pal or not pal:IsValid() then
            print("GetOtomoPal(false) returned nil/invalid — is a Pal actually out as your partner?")
            return
        end

        print("GetOtomoPal(false) returned: " .. pal:GetFullName())
        -- GetFullName() prints as "ClassName /Path/To/Instance" — the first
        -- word IS the real class name we've been hunting for.

        -- Once we see that class name, next step is checking IT for a
        -- passive-related property, e.g.:
        -- print(pal.PassiveSkillList)  -- try this once we know a real field name
    end)
end)

print("[PassiveExtractor Discovery v2] loaded. Have a Pal following you, press F9.")
