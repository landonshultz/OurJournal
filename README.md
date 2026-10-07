# OurJournal

An immersive diary addon for the WoW Forever beta.

## Current state

Version 0.2.0 provides a journal panel with one editable entry per character.
Use `/ourjournal` (or `/oj`) to open or close it, and click Save before
reloading or logging out. Saving replaces that character's previous entry.
Unsaved edits remain in the panel until the UI reloads or the session ends.

Verified in-game on client 1.60.1, build 70245, interface 16001.

## Installation

Place this folder in `_classic_beta_/Interface/AddOns/OurJournal`, then
restart the client and enable OurJournal in the AddOns list.

## Manual test

1. Restart the client after installing this version, then enter the world.
2. Run `/oj`, click the paper area, and write a few lines.
3. Click Save, run `/reload`, then reopen the journal with `/oj`.
4. Check that the saved text is unchanged, including line breaks.
5. Edit the text, close and reopen the panel, and check the draft remains.
6. Reload without saving and check that the last saved text returns.
7. Write enough lines to scroll and check that the cursor remains visible.
8. Log out and back in, then check the saved text again.
9. On another character, check that the journal starts with a separate entry.

Use `/oj build` to report the client version, build, and interface number.

Loading, editing, saving, and restoring text after `/reload` were tested
in the beta client on the build above.

## Files

- `OurJournal.toc`: addon metadata and the list of files WoW loads.
- `OurJournal.lua`: journal panel, saving, and slash commands.

## Development

Keep changes small and review the diff before committing. Test behavior
inside the beta client, since its Lua environment supplies the WoW APIs.
