--[[
  DISCOVERY SCRIPT v5 — we found the real widget classes:
    Parent: WBP_IngameMenu_PalBox_PalDetail_C
    Child (x4): WBP_MainMenu_Pal_Skill_Passive_C

  This version grabs the live parent widget directly by class name, then
  tries a list of plausible property names on it (and on the first
  passive-slot child) to find which one holds the Pal reference / the
  passive identity. Wrapped in pcall so a wrong guess just prints "nil"
  or an error instead of crashing.

  HOW TO USE:
    1. Open a Pal's detail page (same as before).
    2. Press F9.
    3. Read the console/log for any guess that returned something
       non-nil/non-error — that's very likely a real hit.
]]

local function try_prop(obj, prop_name, label)
    if not obj then
        print(string.format("  %s.%s -> (object is nil)", label, prop_name))
        return
    end
    local ok, val = pcall(function() return obj[prop_name] end)
    if not ok then
        print(string.format("  %s.%s -> ERROR: %s", label, prop_name, tostring(val)))
        return
    end
    if val == nil then
        print(string.format("  %s.%s -> nil", label, prop_name))
        return
    end
    -- If it's a UObject-like thing, try GetFullName on it for a readable result
    local ok2, full = pcall(function() return val:GetFullName() end)
    if ok2 and full then
        print(string.format("  %s.%s -> OBJECT: %s", label, prop_name, full))
    else
        print(string.format("  %s.%s -> VALUE: %s", label, prop_name, tostring(val)))
    end
end

RegisterKeyBind(Key.F9, function()
    ExecuteInGameThread(function()
        print("=== [PassiveExtractor Discovery v5] F9 pressed ===")

        local detail = FindFirstOf("WBP_IngameMenu_PalBox_PalDetail_C")
        if not detail or not detail:IsValid() then
            print("WBP_IngameMenu_PalBox_PalDetail_C: NOT FOUND/VALID — is the detail page open?")
            return
        end
        print("Detail widget found: " .. detail:GetFullName())

        print("-- Guessing Pal-reference property names on the detail widget --")
        local candidates = {
            "TargetPal", "TargetPalCharacter", "OwnerPal", "OwnerPalCharacter",
            "CurrentPal", "CurrentPalCharacter", "PalHandle", "PalCharacterHandle",
            "IndividualCharacterHandle", "ViewPalHandle", "SelectPal", "SelectedPal",
            "PalData", "PalParameter",
        }
        for _, name in ipairs(candidates) do
            try_prop(detail, name, "detail")
        end

        print("-- Guessing passive-identity property names on slot child --")
        local ok, slot = pcall(function() return detail.WidgetTree.WBP_MainMenu_Pal_Skill_Passive end)
        if ok and slot and slot:IsValid() then
            print("Slot widget found: " .. slot:GetFullName())
            local passive_candidates = {
                "PassiveSkillRowName", "PassiveSkillID", "PassiveSkillName",
                "SkillRowName", "RowName", "PassiveID", "WazaID", "SlotIndex", "Index",
            }
            for _, name in ipairs(passive_candidates) do
                try_prop(slot, name, "slot0")
            end
        else
            print("Could not reach detail.WidgetTree.WBP_MainMenu_Pal_Skill_Passive live: " .. tostring(slot))
        end

        print("=== end scan ===")
    end)
end)

print("[PassiveExtractor Discovery v5] loaded. Open a Pal's detail page, THEN press F9.")
