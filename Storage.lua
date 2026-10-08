local _, Journal = ...

local function ValidateDatabase(db)
    if type(db.entries) ~= "table" or type(db.nextId) ~= "number" then
        return false
    end

    local ids = {}
    local highestId = 0
    local count = 0
    for key in pairs(db.entries) do
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
            return false
        end
        count = count + 1
    end
    for _, entry in ipairs(db.entries) do
        if type(entry) ~= "table" or type(entry.id) ~= "number"
            or entry.id < 1 or entry.id % 1 ~= 0 or ids[entry.id]
            or type(entry.text) ~= "string" then
            return false
        end
        if (entry.createdAt ~= nil and type(entry.createdAt) ~= "number")
            or (entry.updatedAt ~= nil and type(entry.updatedAt) ~= "number") then
            return false
        end
        if (entry.title ~= nil and type(entry.title) ~= "string")
            or (entry.location ~= nil and type(entry.location) ~= "string") then
            return false
        end
        ids[entry.id] = true
        highestId = math.max(highestId, entry.id)
    end
    return count == #db.entries and db.nextId > highestId and db.nextId % 1 == 0
end

function Journal.Initialize()
    if OurJournalDB == nil then
        OurJournalDB = { entries = {}, nextId = 1, schemaVersion = 1 }
    elseif type(OurJournalDB) ~= "table" then
        return false
    elseif OurJournalDB.schemaVersion == nil then
        if OurJournalDB.entries ~= nil
            or (OurJournalDB.entry ~= nil and type(OurJournalDB.entry) ~= "string") then
            return false
        end

        local entries = {}
        if OurJournalDB.entry and OurJournalDB.entry ~= "" then
            -- The old editor did not record a creation date.
            entries[1] = { id = 1, text = OurJournalDB.entry }
        end
        OurJournalDB.entries = entries
        OurJournalDB.nextId = #entries + 1
        OurJournalDB.schemaVersion = 1
        OurJournalDB.entry = nil
    end

    -- Leave unsupported data untouched rather than replacing a journal.
    return OurJournalDB.schemaVersion == 1 and ValidateDatabase(OurJournalDB)
end

function Journal.FindEntry(id)
    for index, entry in ipairs(OurJournalDB.entries) do
        if entry.id == id then
            return entry, index
        end
    end
end

function Journal.SaveEntry(id, text, timestamp, title, location)
    if id then
        local entry = Journal.FindEntry(id)
        if not entry then
            return nil
        end
        entry.text = text
        entry.title = title or entry.title
        entry.updatedAt = timestamp
        return entry.id
    end

    local newId = OurJournalDB.nextId
    OurJournalDB.nextId = newId + 1
    table.insert(OurJournalDB.entries, 1, {
        id = newId,
        text = text,
        title = title or "",
        location = location,
        createdAt = timestamp,
        updatedAt = timestamp,
    })
    return newId
end

function Journal.DeleteEntry(id)
    local entry, index = Journal.FindEntry(id)
    if not entry then
        return false
    end
    table.remove(OurJournalDB.entries, index)
    return true
end
