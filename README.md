# PureCal

A privacy-focused Flutter nutrition tracking app that helps you monitor your daily food intake and achieve your health goals.

## Features

- **Barcode Scanning** - Quickly log food items by scanning product barcodes
- **OpenFoodFacts Integration** - Access a vast database of food products with detailed nutritional information
- **USDA Database Integration** - Search the USDA Standard Reference food composition database
- **Custom Products** - Create and save your own local products with custom nutrition data
- **Meal Tracking** - Organize entries by meal type (breakfast, lunch, dinner, snacks)
- **Nutrition Goals** - Set and track daily targets for calories, protein, fats, and carbohydrates
- **Visual Analytics** - View weekly nutrition trends with interactive charts
- **Frequent Products** - Quick access to your most-used items
- **Data Export** - Export your diary data to CSV format for external analysis
- **Multi-language Support** - Available in English, Spanish, Russian, Polish, and Belarusian
- **Dark Mode** - Choose between light and dark themes

## Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (^3.9.2 or higher)
- Android Studio / Xcode (for mobile development)
- A physical device or emulator

### Setup

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd purecal
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building

Build for Android:
```bash
flutter build apk
```

Build for iOS:
```bash
flutter build ios
```

## Usage

1. **Set Your Goals** - Navigate to the Goals screen to configure your daily nutrition targets
2. **Search for Products** - Use the search function to find products from OpenFoodFacts and USDA databases
3. **Scan Barcodes** - Tap the scanner button to quickly add products by scanning their barcodes
4. **Create Custom Items** - Add products not in the database using the custom product feature
5. **Log Your Meals** - Select portions and add items to your daily diary organized by meal type
6. **Track Progress** - View your daily summary and weekly trends in the Charts screen
7. **Export Data** - Access Settings to export your diary data as CSV

## Supported Languages

PureCal is available in the following languages:
- English (en)
- Spanish (es)
- Russian (ru)
- Polish (pl)
- Belarusian (be)

The app will automatically use your system language if supported, or default to English.

## Privacy & Data

**Your data stays on your device.** PureCal stores all your information locally using SQLite:

- No cloud synchronization or remote servers
- No account registration required
- No personal data collection or tracking
- Product lookups use OpenFoodFacts and USDA public APIs (search queries only)
- All diary entries, custom products, and goals are stored locally on your device
- You have full control over your data with CSV export functionality

## Export Data

Navigate to Settings and use the "Export Data to CSV" option to create a backup of your diary entries. The CSV file can be opened in spreadsheet applications or imported into other tools.

## Acknowledgments

This app is made possible by:

- **[OpenFoodFacts](https://world.openfoodfacts.org/)** - Providing the comprehensive open food products database
- **[USDA FoodData Central](https://fdc.nal.usda.gov/)** - Providing the Standard Reference food composition database
- **Flutter Community** - For the excellent ecosystem of packages:
  - [provider](https://pub.dev/packages/provider) - State management
  - [sqflite](https://pub.dev/packages/sqflite) - Local database
  - [mobile_scanner](https://pub.dev/packages/mobile_scanner) - Barcode scanning
  - [fl_chart](https://pub.dev/packages/fl_chart) - Data visualization
  - And many other open source contributors

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

---

**Note:** This is a personal nutrition tracking tool. For medical advice or dietary planning, please consult with a qualified healthcare professional.
