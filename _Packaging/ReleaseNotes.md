### Added (1.0.9)
- MenuBuilder: SetElementEnabled method for dynamically enabling/disabling menu elements (buttons, checkboxes, radio buttons) after creation

### Changed (1.0.9)
- MenuBuilder: Renamed internal table from `MenuBuilder` to `menuBuilder` (lowercase) for consistency
- MenuBuilder: Simplified menu tag generation - removed verbose prefixes, now uses uniqueTag directly
- MenuItem: Changed KROWI_MENU_LIBRARY_MINOR initialization to direct assignment for consistency