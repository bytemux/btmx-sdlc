# Architecture checklist

Go through it before the first delivery loop. Record each item whose decision is hard to reverse as an ADR (`docs/adr/NNNN-slug.md`).

## Data model
- [ ] Main entities and the relations between them
- [ ] What is the source of truth

## Storage
- [ ] Where the data lives: local (SQLite, files) or backend
- [ ] Storage format

## Sync & backup
- [ ] Is sync between devices needed (iCloud, own backend, none)
- [ ] How to restore data when a device is lost
- [ ] Data export

## Schema migrations
- [ ] How the data format changes between versions
- [ ] How a migration is tested (tests on real data)

## Distribution (Mobile, IOS)
- [ ] How the app gets onto devices
- [ ] Code signing
- [ ] Notarization (macOS)
- [ ] TestFlight / developer account (iOS)
