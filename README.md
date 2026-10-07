# OurJournal

An immersive fantasy diary addon for the WoW Forever beta.

## Current state

Version 0.1.0 loads and provides `/ourjournal` (or `/oj`) to report the
running client version, build, and interface number. The journal panel and
saved entries are the next milestone.

Verified in-game on client 1.60.1, build 70245, interface 16001.

## Installation

Place this folder in `_classic_beta_/Interface/AddOns/OurJournal`, then
restart the client and enable OurJournal in the AddOns list.

## Manual test

1. Enter the world and check for the OurJournal load message in chat.
2. Run `/ourjournal` and check the reported client information.
3. Run `/reload` and check that the load message appears again.

## Files

- `OurJournal.toc`: addon metadata and the list of files WoW loads.
- `OurJournal.lua`: load confirmation and slash commands.

## Development

Keep changes small and review the diff before committing. Test behavior
inside the beta client, since its Lua environment supplies the WoW APIs.
Comments should explain decisions that are not clear from the code itself.
