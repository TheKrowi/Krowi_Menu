### Changed
- Codebase for upload

### Fixed (1.0.5)
- Krowi_PopupDialog reference

### Added (1.0.6)
- MenuBuilder: BindCallbacks utility function to eliminate callback boilerplate
- MenuBuilder: Default implementations for KeyIsTrue and KeyEqualsText using Krowi_Util
- Version constants (MAJOR, MINOR) exposed on all library objects
- Shared KROWI_MENU_LIBRARY_MINOR constant for consistent versioning across all files

### Changed (1.0.7)
- MenuBuilder: Fixed KeyEqualsText callback parameter order to match documentation (filters, keys, value)
- MenuBuilder: Updated CreateRadio methods to support custom value parameter separate from display text

### Added (1.0.7)
- MenuBuilder: CreateCustomCheckbox method for custom checkbox implementations
- MenuBuilder: CreateCustomRadio method for custom radio button implementations