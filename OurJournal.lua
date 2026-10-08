local _, Journal = ...
local journal
local ready = false

local function EntryDate(entry)
    if not entry.createdAt then
        return "Imported entry"
    end
    return date("%Y-%m-%d %H:%M", entry.createdAt)
end

local function CreateJournal()
    local selectedId
    local savedText = ""
    local pendingAction
    local rows = {}

    local frame = CreateFrame("Frame", "OurJournalFrame", UIParent)
    frame:SetSize(760, 460)
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

    local listScroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", 20, -56)
    listScroll:SetSize(182, 300)
    local list = CreateFrame("Frame", nil, listScroll)
    list:SetSize(182, 300)
    listScroll:SetScrollChild(list)

    local empty = list:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    empty:SetPoint("TOPLEFT", 4, -8)
    empty:SetWidth(174)
    empty:SetJustifyH("LEFT")
    empty:SetText("No entries yet. Click New to begin.")

    local heading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heading:SetPoint("TOPLEFT", 246, -48)
    heading:SetText("New entry")

    local paper = CreateFrame("Frame", nil, frame)
    paper:SetPoint("TOPLEFT", 238, -72)
    paper:SetPoint("BOTTOMRIGHT", -18, 94)
    paper:EnableMouse(true)
    local paperBackground = paper:CreateTexture(nil, "BACKGROUND")
    paperBackground:SetAllPoints()
    paperBackground:SetColorTexture(0.92, 0.86, 0.73, 1)

    local scroll = CreateFrame("ScrollFrame", nil, paper, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -10)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)
    local editor = CreateFrame("EditBox", nil, scroll)
    editor:SetMultiLine(true)
    editor:SetAutoFocus(false)
    editor:SetFontObject("ChatFontNormal")
    editor:SetTextColor(0.08, 0.06, 0.04)
    editor:SetShadowOffset(0, 0)
    local font = editor:GetFont()
    editor:SetFont(font, 14, "")
    editor:SetSize(464, 274)
    scroll:SetScrollChild(editor)

    local function FocusEditor(self, button)
        if button == "LeftButton" and not pendingAction then
            editor:SetFocus()
        end
    end
    paper:SetScript("OnMouseDown", FocusEditor)
    scroll:EnableMouse(true)
    scroll:HookScript("OnMouseDown", FocusEditor)

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("BOTTOMLEFT", 20, 66)
    status:SetWidth(720)
    status:SetJustifyH("LEFT")

    local function Button(label, width, x)
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(width, 26)
        button:SetPoint("BOTTOMLEFT", x, 20)
        button:SetText(label)
        return button
    end

    local new = Button("New", 90, 20)
    local delete = Button("Delete", 90, 120)
    local save = Button("Save", 100, 640)
    local confirm = Button("Confirm", 150, 480)
    local cancel = Button("Cancel", 100, 640)
    confirm:Hide()
    cancel:Hide()

    local function EndConfirmation()
        pendingAction = nil
        confirm:Hide()
        cancel:Hide()
        save:Show()
        new:Enable()
        delete:SetEnabled(selectedId ~= nil)
        editor:EnableMouse(true)
    end

    local function Ask(message, label, action)
        if pendingAction then
            return
        end
        pendingAction = action
        editor:ClearFocus()
        editor:EnableMouse(false)
        new:Disable()
        delete:Disable()
        save:Hide()
        confirm:SetText(label)
        confirm:Show()
        cancel:Show()
        status:SetText(message)
    end

    local function Dirty()
        return editor:GetText() ~= savedText
    end

    local RefreshList
    local function OpenEntry(id)
        local entry = id and Journal.FindEntry(id)
        selectedId = entry and entry.id or nil
        savedText = entry and entry.text or ""
        editor:SetText(savedText)
        editor:ClearFocus()
        scroll:SetVerticalScroll(0)
        heading:SetText(entry and EntryDate(entry) or "New entry")
        status:SetText(entry and "Saved entry" or "Write an entry, then click Save.")
        delete:SetEnabled(selectedId ~= nil)
        RefreshList()
    end

    local function RequestEntry(id)
        if pendingAction then
            return
        end
        if id and id == selectedId then
            return
        end
        if Dirty() then
            Ask("Discard unsaved changes? Cancel to return and save them.", "Discard draft", function()
                OpenEntry(id)
            end)
        else
            OpenEntry(id)
        end
    end

    RefreshList = function()
        local entries = OurJournalDB.entries
        empty:SetShown(#entries == 0)
        for index, entry in ipairs(entries) do
            local row = rows[index]
            if not row then
                row = CreateFrame("Button", nil, list)
                row:SetSize(182, 52)
                row:SetPoint("TOPLEFT", 0, -(index - 1) * 56)
                row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
                row.selected = row:CreateTexture(nil, "BACKGROUND")
                row.selected:SetAllPoints()
                row.selected:SetColorTexture(0.4, 0.3, 0.16, 0.6)
                row.date = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.date:SetPoint("TOPLEFT", 6, -6)
                row.date:SetWidth(170)
                row.date:SetJustifyH("LEFT")
                row.preview = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                row.preview:SetPoint("TOPLEFT", 6, -24)
                row.preview:SetSize(170, 16)
                row.preview:SetJustifyH("LEFT")
                row:SetScript("OnClick", function(self)
                    RequestEntry(self.entryId)
                end)
                rows[index] = row
            end
            row.entryId = entry.id
            row.date:SetText(EntryDate(entry))
            row.preview:SetText(entry.text:match("[^\r\n]+") or "Empty entry")
            row.selected:SetShown(entry.id == selectedId)
            row:Show()
        end
        for index = #entries + 1, #rows do
            rows[index]:Hide()
        end
        list:SetHeight(math.max(300, #entries * 56))
        listScroll:UpdateScrollChildRect()
        listScroll:SetVerticalScroll(math.min(listScroll:GetVerticalScroll(), listScroll:GetVerticalScrollRange()))
    end

    editor:SetScript("OnTextChanged", function(self, userInput)
        scroll:UpdateScrollChildRect()
        if userInput then
            status:SetText(Dirty() and "Unsaved changes" or "No unsaved changes")
        end
    end)
    editor:SetScript("OnEditFocusGained", function(self)
        if pendingAction then
            self:ClearFocus()
        end
    end)
    editor:SetScript("OnCursorChanged", function(self, x, y, width, height)
        local cursorTop = -y
        local offset = scroll:GetVerticalScroll()
        if cursorTop < offset then
            scroll:SetVerticalScroll(math.max(0, cursorTop))
        elseif cursorTop + height > offset + scroll:GetHeight() then
            scroll:SetVerticalScroll(math.max(0, cursorTop + height - scroll:GetHeight()))
        end
    end)
    editor:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        frame:Hide()
    end)
    frame:SetScript("OnHide", function()
        editor:ClearFocus()
        frame:StopMovingOrSizing()
        EndConfirmation()
        status:SetText(Dirty() and "Unsaved changes" or "No unsaved changes")
    end)

    new:SetScript("OnClick", function()
        RequestEntry(nil)
    end)
    save:SetScript("OnClick", function()
        local text = editor:GetText()
        if not text:find("%S") then
            status:SetText("Write something before saving.")
            return
        end
        selectedId = Journal.SaveEntry(selectedId, text, time())
        if not selectedId then
            status:SetText("Unable to find this entry. Your draft is still here.")
            return
        end
        savedText = text
        editor:ClearFocus()
        heading:SetText(EntryDate(Journal.FindEntry(selectedId)))
        delete:Enable()
        status:SetText("Saved")
        RefreshList()
    end)
    delete:SetScript("OnClick", function()
        local id = selectedId
        Ask("Delete this entry and its current draft? This cannot be undone.", "Delete entry", function()
            Journal.DeleteEntry(id)
            OpenEntry(OurJournalDB.entries[1] and OurJournalDB.entries[1].id)
            status:SetText("Entry deleted")
        end)
    end)
    confirm:SetScript("OnClick", function()
        local action = pendingAction
        EndConfirmation()
        if action then
            action()
        end
    end)
    cancel:SetScript("OnClick", function()
        EndConfirmation()
        status:SetText(Dirty() and "Unsaved changes" or "No unsaved changes")
    end)

    OpenEntry(OurJournalDB.entries[1] and OurJournalDB.entries[1].id)
    table.insert(UISpecialFrames, "OurJournalFrame")
    return frame
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "OurJournal" then
        return
    end
    ready = Journal.Initialize()
    if ready then
        print("|cffd8b878OurJournal|r loaded. Type /oj to open your journal.")
    else
        print("|cffd8b878OurJournal|r could not read your saved data. It has been left untouched.")
    end
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
    if not ready then
        print("|cffd8b878OurJournal|r journal unavailable; check the load message for saved-data errors.")
        return
    end
    if not journal then
        journal = CreateJournal()
    end
    journal:SetShown(not journal:IsShown())
end
