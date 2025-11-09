# CHANGELOG

## 0.1.0-beta.2+2

### Added
- Dynamic app version loading from pubspec.yaml
- Portrait-only orientation restriction for better mobile UX

### Changed
- Implemented consistent brand color theme (#74B225 green) with Material 3 patterns
- Refactored AppBar into BrandedAppBar with WCAG-compliant contrast
- Made all UI components theme-aware (eliminated hardcoded colors)

### Fixed
- Fixed FlGridData.horizontalInterval zero assertion error in charts
- Fixed deprecated surfaceVariant usage - replaced with surfaceContainerHighest

## 0.1.0-beta.1+1

### Added
- Daily food intake tracking (calories, macronutrients)
- Barcode scanning for product information retrieval
- Local data storage using SQLite database
- State management with Provider
- Charts for calorie and macronutrient trends (using fl_chart)
- HTTP requests for API interaction
- Multiple screens: Home, Goals, Charts, Create Local Product, Local Products List, Product Detail, Quick Add, Scanner, Search, Settings
- Internationalization support (multiple languages)
