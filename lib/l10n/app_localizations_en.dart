// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PureCal';

  @override
  String get homeTitle => 'PureCal';

  @override
  String get setGoals => 'Set Goals';

  @override
  String get viewCharts => 'View Charts';

  @override
  String get settings => 'Settings';

  @override
  String get searchProducts => 'Search Products';

  @override
  String get nutritionCharts => 'Nutrition Charts';

  @override
  String get setYourGoals => 'Set Your Goals';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get myProducts => 'My Products';

  @override
  String get manageYourCustomProducts => 'Manage your custom products';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get createProduct => 'Create Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snacks => 'Snacks';

  @override
  String addToMeal(String mealType) {
    return 'Add to $mealType';
  }

  @override
  String scanForMeal(String mealType) {
    return 'Scan for $mealType';
  }

  @override
  String noItemsForMeal(String mealType) {
    return 'No items for $mealType yet';
  }

  @override
  String get summary => 'Summary';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get fat => 'Fat';

  @override
  String get carbs => 'Carbs';

  @override
  String get carbohydrates => 'Carbohydrates';

  @override
  String macrosSummary(double protein, double fat, double carbs) {
    return '${protein}g P / ${fat}g F / ${carbs}g C';
  }

  @override
  String get kcal => 'kcal';

  @override
  String get grams => 'g';

  @override
  String get nutritionPer100g => 'Nutrition per 100g:';

  @override
  String get yourPortion => 'Your portion:';

  @override
  String get goalAchievement => 'Goal Achievement';

  @override
  String get dailyNutritionGoals => 'Daily Nutrition Goals';

  @override
  String get setDailyTargets =>
      'Set your daily targets for calories and macronutrients';

  @override
  String get actual => 'Actual';

  @override
  String get goal => 'Goal';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get clear => 'Clear';

  @override
  String get saveGoals => 'Save Goals';

  @override
  String get createProductButton => 'Create Product';

  @override
  String get updateProduct => 'Update Product';

  @override
  String get addToDiary => 'Add to Diary';

  @override
  String get tapPlusToAdd => 'Tap the + button to add';

  @override
  String get searchProductsHint => 'Search products...';

  @override
  String get searching => 'Searching...';

  @override
  String get searchForProducts => 'Search for products by name';

  @override
  String get searchExamples => 'Try \"yogurt\", \"bread\", \"apple\"...';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get frequentlyUsed => 'Frequently Used';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get noCustomProductsYet => 'No custom products yet';

  @override
  String get productName => 'Product Name';

  @override
  String get productNameRequired => 'Product Name *';

  @override
  String get brand => 'Brand';

  @override
  String get barcodeOptional => 'Barcode (optional)';

  @override
  String get portionSize => 'Portion Size';

  @override
  String get gramsUnit => 'grams';

  @override
  String get typicalServingSize => 'Typical Serving Size (g)';

  @override
  String get pleaseEnterProductName => 'Please enter a product name';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get valueMustBeNonNegative => 'Value must be non-negative';

  @override
  String get leaveEmptyForHomemade => 'Leave empty for homemade items';

  @override
  String get additionalInformation =>
      'Additional information about this product';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String deleteProductConfirmation(String productName) {
    return 'Are you sure you want to delete \"$productName\"?';
  }

  @override
  String get productNotFoundDialog => 'Product Not Found';

  @override
  String noProductFoundWithBarcode(String barcode) {
    return 'No product found with barcode: $barcode';
  }

  @override
  String get createCustomProductPrompt =>
      'Would you like to create a custom product with this barcode?';

  @override
  String get goalsUpdatedSuccessfully => 'Goals updated successfully';

  @override
  String addedProductToMeal(String productName, String mealType) {
    return 'Added $productName to $mealType';
  }

  @override
  String get productCreatedSuccessfully => 'Product created successfully';

  @override
  String get productUpdatedSuccessfully => 'Product updated successfully';

  @override
  String errorLoadingProduct(String error) {
    return 'Error loading product: $error';
  }

  @override
  String get loadingProduct => 'Loading product...';

  @override
  String get appearance => 'Appearance';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get manageDataExportImport => 'Export, import, and manage data';

  @override
  String get dataExport => 'Data Export';

  @override
  String get dataImport => 'Data Import';

  @override
  String get cacheManagement => 'Cache Management';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get theme => 'Theme';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get clearFrequentProductsCache => 'Clear Frequent Products Cache';

  @override
  String get clearFrequentProductsDescription =>
      'Remove all frequently used products history';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheConfirmation =>
      'Are you sure you want to clear your frequent products cache? This will remove all usage history.';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get appVersion => 'App Version';

  @override
  String get loading => 'Loading...';

  @override
  String get appDescription =>
      'A food diary app to track your daily nutrition and reach your goals.';

  @override
  String get openFoodFacts => 'Open Food Facts';

  @override
  String get openFoodFactsAttribution =>
      'Product data provided by Open Food Facts';

  @override
  String get openFoodFactsDescription =>
      'This app uses product data from Open Food Facts, a free and open database of food products from around the world.';

  @override
  String get today => 'Today';

  @override
  String get week => 'Week';

  @override
  String get loadingCharts => 'Loading charts...';

  @override
  String get weeklyCalorieTrend => 'Weekly Calorie Trend';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get todaysMacroBreakdown => 'Today\'s Macro Breakdown';

  @override
  String get noMacroDataForToday => 'No macro data for today';

  @override
  String get addSomeFoodToSeeMacros =>
      'Add some food to see your macro breakdown';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$count $_temp0';
  }

  @override
  String get pointCameraAtBarcode => 'Point your camera at a barcode to scan';

  @override
  String get error => 'Error';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get mealType => 'Meal Type';

  @override
  String get notes => 'Notes';

  @override
  String get image => 'Image';

  @override
  String get changeImage => 'Change Image';

  @override
  String get addImage => 'Add Image';

  @override
  String failedToLoadChartData(String error) {
    return 'Failed to load chart data: $error';
  }

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get weeklyMacroTrends => 'Weekly Macro Trends';

  @override
  String get proteinFatCarbsGrams => 'Protein, Fat & Carbs (grams)';

  @override
  String errorPickingImage(String error) {
    return 'Error picking image: $error';
  }

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String errorSavingProduct(String error) {
    return 'Error saving product: $error';
  }

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get caloriesKcalRequired => 'Calories (kcal) *';

  @override
  String get proteinGramsRequired => 'Protein (g) *';

  @override
  String get fatGramsRequired => 'Fat (g) *';

  @override
  String get carbohydratesGramsRequired => 'Carbohydrates (g) *';

  @override
  String errorLoadingProducts(String error) {
    return 'Error loading products: $error';
  }

  @override
  String get productDeleted => 'Product deleted';

  @override
  String errorDeletingProduct(String error) {
    return 'Error deleting product: $error';
  }

  @override
  String kcalPer100g(String calories) {
    return '$calories kcal per 100g';
  }

  @override
  String get custom => 'Custom';

  @override
  String get slashSeparator => ' / ';

  @override
  String get goalsRecommendation =>
      'These goals are general recommendations. Consult a nutritionist for personalized advice.';

  @override
  String failedToFetchProduct(String error) {
    return 'Failed to fetch product: $error';
  }

  @override
  String errorSearching(String error) {
    return 'Error searching: $error';
  }

  @override
  String get exportDiaryEntries => 'Export Diary Entries';

  @override
  String get exportDiaryEntriesDescription =>
      'Export your food diary to CSV format';

  @override
  String get exportingData => 'Exporting data...';

  @override
  String get exportSuccess => 'Diary exported successfully!';

  @override
  String get exportError => 'Failed to export data';

  @override
  String get noDataToExport => 'No diary entries to export';

  @override
  String get selectExportTimeframe => 'Select Export Timeframe';

  @override
  String get allTime => 'All Time';

  @override
  String get exportAllEntries => 'Export all diary entries';

  @override
  String get exportLast7Days => 'Export entries from the last 7 days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get exportLast30Days => 'Export entries from the last 30 days';

  @override
  String get exportProducts => 'Export Products';

  @override
  String get exportProductsDescription =>
      'Export your local products to JSON format';

  @override
  String get exportProductsSuccess => 'Products exported successfully!';

  @override
  String get noProductsToExport => 'No local products to export';

  @override
  String get importProducts => 'Import Products';

  @override
  String get importProductsDescription => 'Import products from a JSON file';

  @override
  String get importingProducts => 'Importing Products';

  @override
  String importingProductsProgress(int current, int total) {
    return 'Importing $current of $total products...';
  }

  @override
  String get importComplete => 'Import Complete';

  @override
  String get importError => 'Import failed';

  @override
  String get imported => 'Imported';

  @override
  String get skipped => 'Skipped';

  @override
  String get errors => 'Errors';

  @override
  String get errorDetails => 'Error Details';

  @override
  String get close => 'Close';

  @override
  String get productConflictTitle => 'Product Conflict';

  @override
  String get productConflictMessage =>
      'A product with this barcode already exists. What would you like to do?';

  @override
  String get existingProduct => 'Existing';

  @override
  String get importedProduct => 'Import';

  @override
  String get keepExisting => 'Keep Existing';

  @override
  String get replaceWithImport => 'Replace';

  @override
  String get keepAllRemaining => 'Keep All Remaining';

  @override
  String get replaceAllRemaining => 'Replace All Remaining';

  @override
  String get productDetails => 'Product Details';

  @override
  String get barcode => 'Barcode';

  @override
  String get basedOnOffProduct => 'Based on OpenFoodFacts product';
}
