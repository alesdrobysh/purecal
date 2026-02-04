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

## Releasing

PureCal uses an automated release script that leverages LLM analysis to determine semantic versioning and generate changelogs.

### Prerequisites for Releases

- **Git repository** with clean working directory
- **LLM Backend** (choose one):
  - Gemini API: Set `GEMINI_API_KEY` environment variable (get free key at [ai.google.dev](https://ai.google.dev/))
  - Ollama: Install locally from [ollama.ai](https://ollama.ai/)
- **GitHub CLI** (`gh`): For creating GitHub releases (optional)
- **Environment file**: `.env.json` with USDA_API_KEY for APK builds

### Quick Release

```bash
# Set Gemini API key (recommended)
export GEMINI_API_KEY=your-api-key

# Run release script
./release.sh
```

The script will:
1. Analyze git changes since last release using LLM
2. Suggest semantic version bump (major/minor/patch)
3. Auto-increment build number
4. Update `pubspec.yaml` and `CHANGELOG.md`
5. Create git commit and tag
6. Push to remote repository
7. Build Android APK (signed)
8. Create GitHub release with APK attachment

### Configuration

Create `.release.config` (optional) to customize behavior:

```bash
# Copy example configuration
cp .release.config.example .release.config

# Edit with your preferences
nano .release.config
```

Available options:
- `LLM_BACKEND`: `auto` (default), `gemini`, or `ollama`
- `GEMINI_API_KEY`: Your Gemini API key
- `GEMINI_MODEL`: Model to use (default: `gemini-2.0-flash-exp`)
- `OLLAMA_MODEL`: Local model (default: `llama3:latest`)
- `BUILD_APK`: Build Android APK (`yes`/`no`)
- `CREATE_GITHUB_RELEASE`: Create GitHub release (`yes`/`no`)
- `PUSH_TO_REMOTE`: Push to git remote (`yes`/`no`)

### Manual Release Steps

If you prefer manual releases:

```bash
# 1. Update version in pubspec.yaml
# 2. Update CHANGELOG.md
# 3. Commit and tag
git add pubspec.yaml CHANGELOG.md
git commit -m "Release 1.0.0+1"
git tag -a v1.0.0+1 -m "Release 1.0.0+1"
git push && git push --tags

# 4. Build APK
flutter build apk --dart-define-from-file=.env.json

# 5. Create GitHub release
gh release create v1.0.0+1 build/app/outputs/flutter-apk/app-release.apk \
  --title "Release 1.0.0+1" --notes "Release notes here"
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
  - [flutter_zxing](https://pub.dev/packages/flutter_zxing) - Barcode scanning
  - [fl_chart](https://pub.dev/packages/fl_chart) - Data visualization
  - And many other open source contributors

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

---

**Note:** This is a personal nutrition tracking tool. For medical advice or dietary planning, please consult with a qualified healthcare professional.
