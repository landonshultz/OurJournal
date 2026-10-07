local Journal = {}
assert(loadfile("Storage.lua"))("OurJournal", Journal)

OurJournalDB = nil
assert(Journal.Initialize())
assert(#OurJournalDB.entries == 0 and OurJournalDB.nextId == 1)

local firstId = Journal.SaveEntry(nil, "First entry\nSecond line", 1000)
local secondId = Journal.SaveEntry(nil, "Another day", 2000)
assert(firstId ~= secondId)
assert(OurJournalDB.entries[1].id == secondId)
assert(Journal.FindEntry(firstId).text == "First entry\nSecond line")

assert(Journal.SaveEntry(firstId, "Revised entry", 3000) == firstId)
assert(Journal.FindEntry(firstId).createdAt == 1000)
assert(Journal.FindEntry(firstId).updatedAt == 3000)
assert(Journal.FindEntry(secondId).text == "Another day")
assert(#OurJournalDB.entries == 2)

assert(Journal.DeleteEntry(secondId))
assert(not Journal.FindEntry(secondId))
assert(Journal.FindEntry(firstId).text == "Revised entry")
local thirdId = Journal.SaveEntry(nil, "Next entry", 4000)
assert(thirdId > secondId)
assert(not Journal.DeleteEntry(999))
assert(Journal.SaveEntry(999, "Missing entry", 5000) == nil)
assert(#OurJournalDB.entries == 2)

assert(Journal.Initialize())
assert(#OurJournalDB.entries == 2)
assert(Journal.FindEntry(firstId).text == "Revised entry")

OurJournalDB = { entry = "Old journal\nWith line breaks" }
assert(Journal.Initialize())
assert(#OurJournalDB.entries == 1)
assert(OurJournalDB.entries[1].text == "Old journal\nWith line breaks")
assert(OurJournalDB.entries[1].createdAt == nil)
assert(OurJournalDB.nextId == 2 and OurJournalDB.entry == nil)
assert(Journal.Initialize())
assert(#OurJournalDB.entries == 1)

OurJournalDB = { entry = "" }
assert(Journal.Initialize())
assert(#OurJournalDB.entries == 0)

OurJournalDB = { schemaVersion = 99, entry = "Keep this" }
assert(not Journal.Initialize())
assert(OurJournalDB.entry == "Keep this" and OurJournalDB.entries == nil)

OurJournalDB = { entry = 123 }
assert(not Journal.Initialize())
assert(OurJournalDB.entry == 123 and OurJournalDB.schemaVersion == nil)

OurJournalDB = {
    schemaVersion = 1, nextId = 2,
    entries = { { id = 1, text = "A" }, { id = 1, text = "B" } },
}
assert(not Journal.Initialize())
assert(#OurJournalDB.entries == 2)

OurJournalDB = {
    schemaVersion = 1, nextId = 2,
    entries = { [2] = { id = 1, text = "Keep this too" } },
}
assert(not Journal.Initialize())
assert(OurJournalDB.entries[2].text == "Keep this too")

print("Storage checks passed: migration, entry IDs, editing, deletion, and data preservation.")
