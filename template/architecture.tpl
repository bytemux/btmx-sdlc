# Architecture checklist

Пройти перед первым delivery loop. Каждый пункт, где решение трудно отменить, оформить как ADR (`docs/adr/NNNN-slug.md`).

## Data model
- [ ] Основные entities и связи между ними
- [ ] Что является source of truth

## Storage
- [ ] Где живут данные: local (SQLite, files) или backend
- [ ] Формат хранения

## Sync & backup
- [ ] Нужна ли sync между устройствами (iCloud, свой backend, нет)
- [ ] Как восстановить данные при потере устройства
- [ ] Export данных

## Schema migrations
- [ ] Как меняется формат данных между версиями
- [ ] Как проверяется migration (tests на реальных данных)

## Distribution (Mobile, IOS)
- [ ] Как приложение попадает на устройства
- [ ] Code signing
- [ ] Notarization (macOS)
- [ ] TestFlight / developer account (iOS)
