import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_be.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('be'),
    Locale('en'),
    Locale('es'),
    Locale('pl'),
    Locale('ru'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'PureCal'**
  String get appTitle;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'PureCal'**
  String get homeTitle;

  /// Button to navigate to goals screen
  ///
  /// In en, this message translates to:
  /// **'Set Goals'**
  String get setGoals;

  /// Button to navigate to charts screen
  ///
  /// In en, this message translates to:
  /// **'View Charts'**
  String get viewCharts;

  /// Settings screen title and navigation button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Search screen title
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get searchProducts;

  /// Charts screen title
  ///
  /// In en, this message translates to:
  /// **'Nutrition Charts'**
  String get nutritionCharts;

  /// Goals screen title
  ///
  /// In en, this message translates to:
  /// **'Set Your Goals'**
  String get setYourGoals;

  /// Scanner screen title and button
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// Local products screen title and button
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// Subtitle for My Products list tile
  ///
  /// In en, this message translates to:
  /// **'Manage your custom products'**
  String get manageYourCustomProducts;

  /// Quick add screen title and button
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// Create local product screen title
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get createProduct;

  /// Edit local product screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// Breakfast meal type
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// Lunch meal type
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// Dinner meal type
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// Snacks meal type
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// Title for adding product to a specific meal
  ///
  /// In en, this message translates to:
  /// **'Add to {mealType}'**
  String addToMeal(String mealType);

  /// Scanner screen subtitle when scanning for a specific meal
  ///
  /// In en, this message translates to:
  /// **'Scan for {mealType}'**
  String scanForMeal(String mealType);

  /// Empty state message for meal section
  ///
  /// In en, this message translates to:
  /// **'No items for {mealType} yet'**
  String noItemsForMeal(String mealType);

  /// Daily summary section title
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// Calories nutrition label
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// Protein nutrition label
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// Fat nutrition label
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// Carbohydrates nutrition label (short form)
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// Carbohydrates nutrition label (long form)
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates;

  /// Summary of macronutrients (protein, fat, carbs)
  ///
  /// In en, this message translates to:
  /// **'{protein}g P / {fat}g F / {carbs}g C'**
  String macrosSummary(double protein, double fat, double carbs);

  /// Kilocalories unit abbreviation
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// Grams unit abbreviation
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get grams;

  /// Label for nutrition values per 100 grams
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100g:'**
  String get nutritionPer100g;

  /// Label for calculated portion nutrition
  ///
  /// In en, this message translates to:
  /// **'Your portion:'**
  String get yourPortion;

  /// Section title for goal progress
  ///
  /// In en, this message translates to:
  /// **'Goal Achievement'**
  String get goalAchievement;

  /// Subtitle for goals screen
  ///
  /// In en, this message translates to:
  /// **'Daily Nutrition Goals'**
  String get dailyNutritionGoals;

  /// Description text for goals screen
  ///
  /// In en, this message translates to:
  /// **'Set your daily targets for calories and macronutrients'**
  String get setDailyTargets;

  /// Label for actual values in charts
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// Label for goal values in charts
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Clear button label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Save goals button label
  ///
  /// In en, this message translates to:
  /// **'Save Goals'**
  String get saveGoals;

  /// Create product button label
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get createProductButton;

  /// Update product button label
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// Add to diary button label
  ///
  /// In en, this message translates to:
  /// **'Add to Diary'**
  String get addToDiary;

  /// Instruction text for empty states
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add'**
  String get tapPlusToAdd;

  /// Search input hint text
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProductsHint;

  /// Loading state for search
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// Empty state instruction
  ///
  /// In en, this message translates to:
  /// **'Search for products by name'**
  String get searchForProducts;

  /// Search examples hint
  ///
  /// In en, this message translates to:
  /// **'Try \"yogurt\", \"bread\", \"apple\"...'**
  String get searchExamples;

  /// Empty search results message
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// Section title for frequent products
  ///
  /// In en, this message translates to:
  /// **'Frequently Used'**
  String get frequentlyUsed;

  /// Error when product lookup fails
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// Empty state for local products list
  ///
  /// In en, this message translates to:
  /// **'No custom products yet'**
  String get noCustomProductsYet;

  /// Product name field label
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// Product name field label with required indicator
  ///
  /// In en, this message translates to:
  /// **'Product Name *'**
  String get productNameRequired;

  /// Brand field label
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// Barcode field label
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get barcodeOptional;

  /// Portion size field label
  ///
  /// In en, this message translates to:
  /// **'Portion Size'**
  String get portionSize;

  /// Grams unit for form fields
  ///
  /// In en, this message translates to:
  /// **'grams'**
  String get gramsUnit;

  /// Serving size field label
  ///
  /// In en, this message translates to:
  /// **'Typical Serving Size (g)'**
  String get typicalServingSize;

  /// Validation error for empty product name
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get pleaseEnterProductName;

  /// Validation error for invalid number input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// Generic required field validation error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Validation error for negative numbers
  ///
  /// In en, this message translates to:
  /// **'Value must be non-negative'**
  String get valueMustBeNonNegative;

  /// Helper text for barcode field
  ///
  /// In en, this message translates to:
  /// **'Leave empty for homemade items'**
  String get leaveEmptyForHomemade;

  /// Helper text for notes field
  ///
  /// In en, this message translates to:
  /// **'Additional information about this product'**
  String get additionalInformation;

  /// Delete product dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// Delete product confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{productName}\"?'**
  String deleteProductConfirmation(String productName);

  /// Product not found dialog title
  ///
  /// In en, this message translates to:
  /// **'Product Not Found'**
  String get productNotFoundDialog;

  /// Product not found error message
  ///
  /// In en, this message translates to:
  /// **'No product found with barcode: {barcode}'**
  String noProductFoundWithBarcode(String barcode);

  /// Prompt to create custom product after failed barcode lookup
  ///
  /// In en, this message translates to:
  /// **'Would you like to create a custom product with this barcode?'**
  String get createCustomProductPrompt;

  /// Success message after saving goals
  ///
  /// In en, this message translates to:
  /// **'Goals updated successfully'**
  String get goalsUpdatedSuccessfully;

  /// Success message after adding product to diary
  ///
  /// In en, this message translates to:
  /// **'Added {productName} to {mealType}'**
  String addedProductToMeal(String productName, String mealType);

  /// Success message after creating custom product
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get productCreatedSuccessfully;

  /// Success message after updating custom product
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// Error message when product loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading product: {error}'**
  String errorLoadingProduct(String error);

  /// Loading message during product fetch
  ///
  /// In en, this message translates to:
  /// **'Loading product...'**
  String get loadingProduct;

  /// Appearance settings section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Data management settings section title
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Data management subtitle description
  ///
  /// In en, this message translates to:
  /// **'Export, import, and manage data'**
  String get manageDataExportImport;

  /// Data export section title
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get dataExport;

  /// Data import section title
  ///
  /// In en, this message translates to:
  /// **'Data Import'**
  String get dataImport;

  /// Cache management section title
  ///
  /// In en, this message translates to:
  /// **'Cache Management'**
  String get cacheManagement;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// System default language/theme option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Theme settings label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Theme picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// Clear cache button label
  ///
  /// In en, this message translates to:
  /// **'Clear Frequent Products Cache'**
  String get clearFrequentProductsCache;

  /// Clear cache description
  ///
  /// In en, this message translates to:
  /// **'Remove all frequently used products history'**
  String get clearFrequentProductsDescription;

  /// Clear cache dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Clear cache confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear your frequent products cache? This will remove all usage history.'**
  String get clearCacheConfirmation;

  /// Success message after clearing cache
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Generic loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// App description text
  ///
  /// In en, this message translates to:
  /// **'A food diary app to track your daily nutrition and reach your goals.'**
  String get appDescription;

  /// Open Food Facts attribution title
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts'**
  String get openFoodFacts;

  /// Open Food Facts attribution subtitle
  ///
  /// In en, this message translates to:
  /// **'Product data provided by Open Food Facts'**
  String get openFoodFactsAttribution;

  /// Open Food Facts full description
  ///
  /// In en, this message translates to:
  /// **'This app uses product data from Open Food Facts, a free and open database of food products from around the world.'**
  String get openFoodFactsDescription;

  /// Today tab label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Week tab label
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Loading state for charts
  ///
  /// In en, this message translates to:
  /// **'Loading charts...'**
  String get loadingCharts;

  /// Weekly calorie chart title
  ///
  /// In en, this message translates to:
  /// **'Weekly Calorie Trend'**
  String get weeklyCalorieTrend;

  /// Time range subtitle for charts
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// Macro pie chart title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Macro Breakdown'**
  String get todaysMacroBreakdown;

  /// Empty state for macro chart
  ///
  /// In en, this message translates to:
  /// **'No macro data for today'**
  String get noMacroDataForToday;

  /// Empty state instruction for macro chart
  ///
  /// In en, this message translates to:
  /// **'Add some food to see your macro breakdown'**
  String get addSomeFoodToSeeMacros;

  /// Item count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{item} other{items}}'**
  String itemCount(int count);

  /// Scanner instruction text
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a barcode to scan'**
  String get pointCameraAtBarcode;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Generic unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// Meal type field label
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Image field label
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// Change image button label
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// Add image button label
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// Error message when chart data fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load chart data: {error}'**
  String failedToLoadChartData(String error);

  /// Message when no data is available for charts
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Weekly macro chart title
  ///
  /// In en, this message translates to:
  /// **'Weekly Macro Trends'**
  String get weeklyMacroTrends;

  /// Subtitle for weekly macro chart
  ///
  /// In en, this message translates to:
  /// **'Protein, Fat & Carbs (grams)'**
  String get proteinFatCarbsGrams;

  /// Error message when picking image fails
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// Title for image source selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// Option to pick image from camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Option to pick image from gallery
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Error message when saving product fails
  ///
  /// In en, this message translates to:
  /// **'Error saving product: {error}'**
  String errorSavingProduct(String error);

  /// Text for adding product photo
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// Label for required calories input field
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal) *'**
  String get caloriesKcalRequired;

  /// Label for required protein input field
  ///
  /// In en, this message translates to:
  /// **'Protein (g) *'**
  String get proteinGramsRequired;

  /// Label for required fat input field
  ///
  /// In en, this message translates to:
  /// **'Fat (g) *'**
  String get fatGramsRequired;

  /// Label for required carbohydrates input field
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates (g) *'**
  String get carbohydratesGramsRequired;

  /// Error message when loading local products fails
  ///
  /// In en, this message translates to:
  /// **'Error loading products: {error}'**
  String errorLoadingProducts(String error);

  /// Success message after deleting a product
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// Error message when deleting product fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting product: {error}'**
  String errorDeletingProduct(String error);

  /// Calories per 100g format string
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal per 100g'**
  String kcalPer100g(String calories);

  /// Badge text for custom products
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Separator for displaying current/goal values
  ///
  /// In en, this message translates to:
  /// **' / '**
  String get slashSeparator;

  /// Info text about consulting a nutritionist for goals
  ///
  /// In en, this message translates to:
  /// **'These goals are general recommendations. Consult a nutritionist for personalized advice.'**
  String get goalsRecommendation;

  /// Error message when fetching product details fails
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch product: {error}'**
  String failedToFetchProduct(String error);

  /// Error message when product search fails
  ///
  /// In en, this message translates to:
  /// **'Error searching: {error}'**
  String errorSearching(String error);

  /// Title for network error dialog
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get networkErrorTitle;

  /// User-friendly message when product fetch fails due to network issues
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch product information. Please check your internet connection and try again.'**
  String get networkErrorMessage;

  /// Export diary data button label
  ///
  /// In en, this message translates to:
  /// **'Export Diary Entries'**
  String get exportDiaryEntries;

  /// Export diary data description
  ///
  /// In en, this message translates to:
  /// **'Export your food diary to CSV format'**
  String get exportDiaryEntriesDescription;

  /// Loading message during export
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportingData;

  /// Success message after export
  ///
  /// In en, this message translates to:
  /// **'Diary exported successfully!'**
  String get exportSuccess;

  /// Generic export error message
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get exportError;

  /// Error message when there's no data to export
  ///
  /// In en, this message translates to:
  /// **'No diary entries to export'**
  String get noDataToExport;

  /// Dialog title for selecting export timeframe
  ///
  /// In en, this message translates to:
  /// **'Select Export Timeframe'**
  String get selectExportTimeframe;

  /// Option to export all data
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Description for all time export
  ///
  /// In en, this message translates to:
  /// **'Export all diary entries'**
  String get exportAllEntries;

  /// Description for last 7 days export
  ///
  /// In en, this message translates to:
  /// **'Export entries from the last 7 days'**
  String get exportLast7Days;

  /// Option to export last 30 days
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// Description for last 30 days export
  ///
  /// In en, this message translates to:
  /// **'Export entries from the last 30 days'**
  String get exportLast30Days;

  /// Export products button label
  ///
  /// In en, this message translates to:
  /// **'Export Products'**
  String get exportProducts;

  /// Export products description
  ///
  /// In en, this message translates to:
  /// **'Export your local products to JSON format'**
  String get exportProductsDescription;

  /// Success message after exporting products
  ///
  /// In en, this message translates to:
  /// **'Products exported successfully!'**
  String get exportProductsSuccess;

  /// Error message when there are no products to export
  ///
  /// In en, this message translates to:
  /// **'No local products to export'**
  String get noProductsToExport;

  /// Import products button label
  ///
  /// In en, this message translates to:
  /// **'Import Products'**
  String get importProducts;

  /// Import products description
  ///
  /// In en, this message translates to:
  /// **'Import products from a JSON file'**
  String get importProductsDescription;

  /// Dialog title during import
  ///
  /// In en, this message translates to:
  /// **'Importing Products'**
  String get importingProducts;

  /// Progress message during import
  ///
  /// In en, this message translates to:
  /// **'Importing {current} of {total} products...'**
  String importingProductsProgress(int current, int total);

  /// Dialog title when import is complete
  ///
  /// In en, this message translates to:
  /// **'Import Complete'**
  String get importComplete;

  /// Generic import error message
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importError;

  /// Label for number of imported products
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get imported;

  /// Label for number of skipped products
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// Label for number of errors during import
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get errors;

  /// Section header for error messages
  ///
  /// In en, this message translates to:
  /// **'Error Details'**
  String get errorDetails;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Title for conflict resolution dialog
  ///
  /// In en, this message translates to:
  /// **'Product Conflict'**
  String get productConflictTitle;

  /// Message explaining the conflict
  ///
  /// In en, this message translates to:
  /// **'A product with this barcode already exists. What would you like to do?'**
  String get productConflictMessage;

  /// Label for existing product in conflict dialog
  ///
  /// In en, this message translates to:
  /// **'Existing'**
  String get existingProduct;

  /// Label for imported product in conflict dialog
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importedProduct;

  /// Button to keep the existing product
  ///
  /// In en, this message translates to:
  /// **'Keep Existing'**
  String get keepExisting;

  /// Button to replace with imported product
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceWithImport;

  /// Button to keep all remaining conflicting products
  ///
  /// In en, this message translates to:
  /// **'Keep All Remaining'**
  String get keepAllRemaining;

  /// Button to replace all remaining conflicting products
  ///
  /// In en, this message translates to:
  /// **'Replace All Remaining'**
  String get replaceAllRemaining;

  /// Product detail screen title
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// Barcode label
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// Text shown for products edited from OpenFoodFacts
  ///
  /// In en, this message translates to:
  /// **'Based on OpenFoodFacts product'**
  String get basedOnOffProduct;

  /// Text shown for products from USDA database
  ///
  /// In en, this message translates to:
  /// **'From USDA Food Database'**
  String get fromUsdaDatabase;

  /// Text shown for products edited from USDA database
  ///
  /// In en, this message translates to:
  /// **'Based on USDA product'**
  String get basedOnUsdaProduct;

  /// Text shown for custom local products
  ///
  /// In en, this message translates to:
  /// **'Custom product'**
  String get customProduct;

  /// Text shown for products from OpenFoodFacts database
  ///
  /// In en, this message translates to:
  /// **'From OpenFoodFacts'**
  String get fromOpenFoodFacts;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['be', 'en', 'es', 'pl', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'be':
      return AppLocalizationsBe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
