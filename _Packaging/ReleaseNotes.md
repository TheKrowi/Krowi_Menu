### Added (2.2)
- MenuBuilder: `New(config)` takes `modern = true` to build that menu with Blizzard's menu system on any client, not only Retail; set it up with `SetupMenuForModern` or open it with `ShowPopup`, as on Retail. WoW Forever runs Retail's interface and has Blizzard's menus. Without the field every builder works as before

### Fixed (2.2)
- MenuBuilder: `New()` without a config no longer errors

### Changed (2.2)
- MenuBuilder: library version 1 → 2, so this copy replaces an older embedded one
- Updated supported interfaces: `120000, 110207 → 120105` (Midnight 12.1.5), `50503 → 50504` (Mists Classic), `20505 → 20506` (Burning Crusade Anniversary), added `16001` (WoW Forever), `11508 → 11509` (Classic Era)