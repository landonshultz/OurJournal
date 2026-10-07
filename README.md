# OurJournal

An immersive diary addon for the WoW Forever beta.

## Current state

Version 0.3.0 provides a list of entries for each character. Use `/ourjournal`
(or `/oj`) to open or close the journal. Click New to begin an entry, then
Save to add it to the list. Select an existing entry to read or edit it.
Delete asks for confirmation before removing the selected entry.

Save before reloading or logging out. Unsaved edits remain while closing
and reopening the panel, but are lost when the UI reloads or the session ends.
Switching entries or starting a new one asks before discarding unsaved edits.

An entry saved with version 0.2.0 is imported automatically. Since that
version did not record dates, it appears as an Imported entry.

Verified in-game on client 1.60.1, build 70245, interface 16001.

## Installation

Place this folder in `_classic_beta_/Interface/AddOns/OurJournal`, then
restart the client and enable OurJournal in the AddOns list.

## Manual test

1. Restart the client, then open `/oj`. Check that your previous entry is
   listed as Imported entry and its text is unchanged.
2. Click New, write a few lines, and Save. Repeat to create a second entry.
3. Select each entry and check its text. Edit one and Save; check that the
   other entries and the edited entry's creation date remain unchanged.
4. Make an unsaved edit, then select another entry. Cancel the discard
   prompt and check that the draft remains. Try again and discard it.
5. Close and reopen with an unsaved draft, then reload without saving.
   Check that only the saved version returns after the reload.
6. Delete a disposable entry: cancel once, then confirm. Reload and check
   that the entry stays deleted and the others remain.
7. Write enough lines to scroll. Create enough entries to scroll the list.
8. Log out and back in, then check the entries again. On another character,
   check that the journal uses a separate list.

Use `/oj build` to report the client version, build, and interface number.

The entry list, editing, migration, deletion, and reload persistence were
tested in the beta client on the build above.

## Keeping your journal

Entries are stored locally in WoW's WTF folder. They are not uploaded to
GitHub or backed up by this addon. Keep a backup of that folder before
reinstalling the game or moving to another computer. Export and import
are planned.

## Files

- `OurJournal.toc`: addon metadata and the list of files WoW loads.
- `Storage.lua`: saved entries and migration from the single-entry editor.
- `OurJournal.lua`: journal panel, saving, and slash commands.

## Development

Keep changes small and review the diff before committing. Test behavior
inside the beta client, since its Lua environment supplies the WoW APIs.
