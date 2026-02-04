# CHANGELOG


## [1.0.0+6] - 2026-02-04

### Added
-   **Automated Release Process**: Introduced an automated release script to streamline our deployment process, allowing for more consistent and efficient updates.

### Changed
-   **Enhanced Barcode Scanning**: Migrated the barcode scanning functionality to a new library (`flutter_zxing`) for improved performance, reliability, and broader compatibility with various barcode types.
-   **Improved Android Build Process**: Configured Android release signing, a crucial step for ensuring secure and official releases of the app on platforms like the Google Play Store.

## 1.0.0-beta.2+5

### Changed
- Updated application ID to dev.alesdrobysh.purecal (Android)
- Updated bundle identifier to dev.alesdrobysh.purecal (iOS/macOS/Linux)
- Updated namespace to dev.alesdrobysh.purecal across all platforms

## 1.0.0-beta.1+4

### Changed
- Renamed project from FoodieFit to PureCal across all platforms and configurations
- Updated application ID to com.example.purecal (Android)
- Updated bundle identifier to com.example.purecal (iOS/macOS)
- Updated product name and executable name to PureCal in all platform configurations

## 0.1.0-beta.3+3

### Added
- USDA FoodData Central API integration for comprehensive food database access
- Product source enum system (Custom, OpenFoodFacts, USDA Original, USDA Edited)
- Product import/export functionality with JSON format
- Conflict resolution dialog for duplicate products during import
- Import progress dialog with real-time updates
- Dedicated Data Management screen consolidating export, import, and cache operations
- Base64 image encoding/decoding for portable product data
- Skeleton loading widget for product cards
- USDA API key configuration via environment file (.env.json)
- Custom export exceptions (NoDataToExportException, NoProductsToExportException)
- Localization strings for USDA database and product sources in all supported languages

### Changed
- Refactored ProductService to search across local, OpenFoodFacts, and USDA databases
- Updated product search to enforce pageSize limit across all sources
- Refactored import dialog to be stateful with built-in progress management
- Moved data management features from Settings to dedicated screen
- Updated share_plus package usage to SharePlus.instance.share with ShareParams
- Refactored language and theme selection using RadioGroup widget
- Improved app theme with hybrid ColorScheme approach (neutral surfaces with brand accents)
- Defined consistent styles for AppBar, Card, and FloatingActionButton
- Updated diary and product export filenames to "PureCal"
- Generalized local product creation screen to support external source products (OFF, USDA)
- Made USDA nutrient values nullable (returns null if essential data missing)
- Updated error logging from print() to debugPrint() for better production handling

### Fixed
- Fixed existingByBarcode map updates during product import (duplicate detection within same file)
- Fixed defensive numeric field parsing in import service (handles both num and String types)
- Fixed Spanish translations for product labels and import dialog
- Removed unused imports (decorations.dart, custom_colors.dart, intl.dart)
- Replaced deprecated 'value' with 'initialValue' in DropdownButtonFormField

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
