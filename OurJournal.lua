local journal

local function CreateJournal()
    local frame = CreateFrame("Frame", "OurJournalFrame", UIParent)
    frame:SetSize(480, 420)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:Hide()

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.12, 0.09, 0.06, 0.98)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -16)
    title:SetText("OurJournal")

    local handle = CreateFrame("Frame", nil, frame)
    handle:SetPoint("TOPLEFT")
    handle:SetPoint("TOPRIGHT", -36, 0)
    handle:SetHeight(40)
    handle:EnableMouse(true)
    handle:RegisterForDrag("LeftButton")
    handle:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    handle:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
    end)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    local paper = frame:CreateTexture(nil, "BACKGROUND")
    paper:SetPoint("TOPLEFT", 18, -48)
    paper:SetPoint("BOTTOMRIGHT", -18, 60)
    paper:SetColorTexture(0.88, 0.81, 0.65, 1)

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 28, -58)
    scroll:SetPoint("BOTTOMRIGHT", -48, 70)

    local editor = CreateFrame("EditBox", nil, scroll)
    editor:SetMultiLine(true)
    editor:SetAutoFocus(false)
    editor:SetFontObject("ChatFontNormal")
    editor:SetTextColor(0.18, 0.12, 0.07)
    editor:SetWidth(404)
    editor:SetHeight(292)
    scroll:SetScrollChild(editor)

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("BOTTOMLEFT", 20, 26)
    status:SetWidth(300)
    status:SetJustifyH("LEFT")
    status:SetText("One entry for this character. Save before reloading.")

    editor:SetScript("OnTextChanged", function(self, userInput)
        scroll:UpdateScrollChildRect()
        if userInput then
            status:SetText("Unsaved changes")
        end
    end)
    editor:SetScript("OnCursorChanged", function(self, x, y, width, height)
        local cursorTop = -y
        local offset = scroll:GetVerticalScroll()
        local visibleHeight = scroll:GetHeight()
        if cursorTop < offset then
            scroll:SetVerticalScroll(math.max(0, cursorTop))
        elseif cursorTop + height > offset + visibleHeight then
            scroll:SetVerticalScroll(math.max(0, cursorTop + height - visibleHeight))
        end
    end)
    editor:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        frame:Hide()
    end)
    frame:SetScript("OnHide", function()
        editor:ClearFocus()
        frame:StopMovingOrSizing()
    end)

    local save = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    save:SetSize(100, 26)
    save:SetPoint("BOTTOMRIGHT", -20, 20)
    save:SetText("Save")
    save:SetScript("OnClick", function()
        OurJournalDB.entry = editor:GetText()
        editor:ClearFocus()
        status:SetText("Saved")
    end)

    editor:SetText(OurJournalDB.entry)
    table.insert(UISpecialFrames, "OurJournalFrame")
    return frame
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "OurJournal" then
        return
    end

    -- Saved variables are available after our ADDON_LOADED event.
    if type(OurJournalDB) ~= "table" then
        OurJournalDB = {}
    end
    if type(OurJournalDB.entry) ~= "string" then
        OurJournalDB.entry = ""
    end

    print("|cffd8b878OurJournal|r loaded. Type /oj to open your journal.")
    self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_OURJOURNAL1 = "/ourjournal"
SLASH_OURJOURNAL2 = "/oj"
SlashCmdList["OURJOURNAL"] = function(message)
    if message:lower():match("^%s*build%s*$") then
        local version, build, buildDate, interfaceVersion = GetBuildInfo()
        print("|cffd8b878OurJournal|r Client: " .. tostring(version)
            .. " | Build: " .. tostring(build) .. " | Interface: " .. tostring(interfaceVersion))
        return
    end

    if not journal then
        journal = CreateJournal()
    end
    journal:SetShown(not journal:IsShown())
end
