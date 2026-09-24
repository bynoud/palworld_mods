--[[
  DISCOVERY SCRIPT v4 — find the widget behind an ALREADY-OPEN Pal detail
  page, instead of triggering anything ourselves.

  HOW TO USE:
    1. In-game, open a Pal's detail/status page normally (however you'd
       normally check its stats/passives).
    2. While it's still open on screen, press F9.
    3. Read the console/log — it lists every currently-loaded widget whose
       name contains "status" or "detail", which should include the real
       one behind what you're looking at.
]]

local SEARCH_TERMS = {"status", "detail", "palstatus"}

RegisterKeyBind(Key.F9, function()
    ExecuteInGameThread(function()
        print("=== [PassiveExtractor Discovery v4] F9 pressed ===")

        local widgets = FindAllOf("UserWidget") or {}
        print(string.format("Scanning %d loaded UserWidget instances...", #widgets))

        local hits = 0
        for _, w in pairs(widgets) do
            if w and w:IsValid() then
                local ok, full_name = pcall(function() return w:GetFullName() end)
                if ok and full_name then
                    local lower = full_name:lower()
                    for _, term in ipairs(SEARCH_TERMS) do
                        if lower:find(term) then
                            print("MATCH: " .. full_name)
                            hits = hits + 1
                            break
                        end
                    end
                end
            end
        end

        print(string.format("=== end scan — %d match(es). If none, try opening the detail page differently (e.g. from party menu vs. base menu) and re-scan. ===", hits))
    end)
end)

print("[PassiveExtractor Discovery v4] loaded. Open a Pal's detail page, THEN press F9.")
