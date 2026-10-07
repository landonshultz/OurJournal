-- This frame listens for WoW's notification that an addon has loaded.
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "OurJournal" then
        return
    end

    print("|cffd8b878OurJournal|r loaded. Type /ourjournal to check the client build.")
    self:UnregisterEvent("ADDON_LOADED")
end)

-- WoW calls this function when you enter either slash command in chat.
SLASH_OURJOURNAL1 = "/ourjournal"
SLASH_OURJOURNAL2 = "/oj"
SlashCmdList["OURJOURNAL"] = function()
    local version, build, buildDate, interfaceVersion = GetBuildInfo()
    print("|cffd8b878OurJournal|r 0.1.0 is running.")
    print("Client: " .. tostring(version) .. " | Build: " .. tostring(build)
        .. " | Interface: " .. tostring(interfaceVersion))
end
