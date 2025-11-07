// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Belarusian (`be`).
class AppLocalizationsBe extends AppLocalizations {
  AppLocalizationsBe([String locale = 'be']) : super(locale);

  @override
  String get appTitle => 'PureCal';

  @override
  String get homeTitle => 'PureCal';

  @override
  String get setGoals => 'Усталяваць мэты';

  @override
  String get viewCharts => 'Паглядзець графікі';

  @override
  String get settings => 'Налады';

  @override
  String get searchProducts => 'Пошук прадуктаў';

  @override
  String get nutritionCharts => 'Графікі харчавання';

  @override
  String get setYourGoals => 'Усталюйце свае мэты';

  @override
  String get scanBarcode => 'Сканаваць штрых-код';

  @override
  String get myProducts => 'Мае прадукты';

  @override
  String get manageYourCustomProducts =>
      'Кіраванне вашымі карыстальніцкімі прадуктамі';

  @override
  String get quickAdd => 'Хуткае даданне';

  @override
  String get createProduct => 'Стварыць прадукт';

  @override
  String get editProduct => 'Рэдагаваць прадукт';

  @override
  String get breakfast => 'Сняданак';

  @override
  String get lunch => 'Абед';

  @override
  String get dinner => 'Вячэра';

  @override
  String get snacks => 'Перакус';

  @override
  String addToMeal(String mealType) {
    return 'Дадаць да $mealType';
  }

  @override
  String scanForMeal(String mealType) {
    return 'Сканаваць для $mealType';
  }

  @override
  String noItemsForMeal(String mealType) {
    return 'Пакуль няма элементаў для $mealType';
  }

  @override
  String get summary => 'Зводка';

  @override
  String get calories => 'Калорыі';

  @override
  String get protein => 'Бялкі';

  @override
  String get fat => 'Тлушчы';

  @override
  String get carbs => 'Вугляводы';

  @override
  String get carbohydrates => 'Вугляводы';

  @override
  String macrosSummary(double protein, double fat, double carbs) {
    return '$proteinг Б / $fatг Т / $carbsг В';
  }

  @override
  String get kcal => 'ккал';

  @override
  String get grams => 'г';

  @override
  String get nutritionPer100g => 'Харчаванне на 100г:';

  @override
  String get yourPortion => 'Ваша порцыя:';

  @override
  String get goalAchievement => 'Дасягненне мэтаў';

  @override
  String get dailyNutritionGoals => 'Штодзённыя мэты харчавання';

  @override
  String get setDailyTargets =>
      'Усталюйце штодзённыя мэты па калорыях і макранутрыентах';

  @override
  String get actual => 'Фактычна';

  @override
  String get goal => 'Мэта';

  @override
  String get add => 'Дадаць';

  @override
  String get cancel => 'Адмяніць';

  @override
  String get save => 'Захаваць';

  @override
  String get delete => 'Выдаліць';

  @override
  String get edit => 'Рэдагаваць';

  @override
  String get retry => 'Паўтарыць';

  @override
  String get ok => 'ОК';

  @override
  String get clear => 'Ачысціць';

  @override
  String get saveGoals => 'Захаваць мэты';

  @override
  String get createProductButton => 'Стварыць прадукт';

  @override
  String get updateProduct => 'Абнавіць прадукт';

  @override
  String get addToDiary => 'Дадаць у дзённік';

  @override
  String get tapPlusToAdd => 'Націсніце кнопку + каб дадаць';

  @override
  String get searchProductsHint => 'Пошук прадуктаў...';

  @override
  String get searching => 'Пошук...';

  @override
  String get searchForProducts => 'Пошук прадуктаў па назве';

  @override
  String get searchExamples => 'Паспрабуйце \"ёгурт\", \"хлеб\", \"яблык\"...';

  @override
  String get noProductsFound => 'Прадукты не знойдзены';

  @override
  String get frequentlyUsed => 'Часта выкарыстоўваюцца';

  @override
  String get productNotFound => 'Прадукт не знойдзены';

  @override
  String get noCustomProductsYet => 'Пакуль няма карыстальніцкіх прадуктаў';

  @override
  String get productName => 'Назва прадукту';

  @override
  String get productNameRequired => 'Назва прадукту *';

  @override
  String get brand => 'Брэнд';

  @override
  String get barcodeOptional => 'Штрых-код (неабавязкова)';

  @override
  String get portionSize => 'Памер порцыі';

  @override
  String get gramsUnit => 'грамы';

  @override
  String get typicalServingSize => 'Тыповы памер порцыі (г)';

  @override
  String get pleaseEnterProductName => 'Калі ласка, увядзіце назву прадукту';

  @override
  String get pleaseEnterValidNumber => 'Калі ласка, увядзіце дапушчальны лік';

  @override
  String get fieldRequired => 'Гэта поле абавязковае';

  @override
  String get valueMustBeNonNegative => 'Значэнне павінна быць неадмоўным';

  @override
  String get leaveEmptyForHomemade => 'Пакіньце пустым для хатніх прадуктаў';

  @override
  String get additionalInformation => 'Дадатковая інфармацыя пра гэты прадукт';

  @override
  String get deleteProduct => 'Выдаліць прадукт';

  @override
  String deleteProductConfirmation(String productName) {
    return 'Вы ўпэўнены, што хочаце выдаліць \"$productName\"?';
  }

  @override
  String get productNotFoundDialog => 'Прадукт не знойдзены';

  @override
  String noProductFoundWithBarcode(String barcode) {
    return 'Прадукт са штрых-кодам $barcode не знойдзены';
  }

  @override
  String get createCustomProductPrompt =>
      'Хочаце стварыць карыстальніцкі прадукт з гэтым штрых-кодам?';

  @override
  String get goalsUpdatedSuccessfully => 'Мэты паспяхова абноўлены';

  @override
  String addedProductToMeal(String productName, String mealType) {
    return 'Дададзены $productName да $mealType';
  }

  @override
  String get productCreatedSuccessfully => 'Прадукт паспяхова створаны';

  @override
  String get productUpdatedSuccessfully => 'Прадукт паспяхова абноўлены';

  @override
  String errorLoadingProduct(String error) {
    return 'Памылка загрузкі прадукту: $error';
  }

  @override
  String get loadingProduct => 'Загрузка прадукту...';

  @override
  String get appearance => 'Знешні выгляд';

  @override
  String get dataManagement => 'Кіраванне данымі';

  @override
  String get about => 'Пра праграму';

  @override
  String get language => 'Мова';

  @override
  String get chooseLanguage => 'Выбраць мову';

  @override
  String get systemDefault => 'Сістэмны па змаўчанні';

  @override
  String get theme => 'Тэма';

  @override
  String get chooseTheme => 'Выбраць тэму';

  @override
  String get lightTheme => 'Светлая тэма';

  @override
  String get darkTheme => 'Цёмная тэма';

  @override
  String get clearFrequentProductsCache =>
      'Ачысціць кэш часта выкарыстоўваных прадуктаў';

  @override
  String get clearFrequentProductsDescription =>
      'Выдаліць усю гісторыю часта выкарыстоўваных прадуктаў';

  @override
  String get clearCache => 'Ачысціць кэш';

  @override
  String get clearCacheConfirmation =>
      'Вы ўпэўнены, што хочаце ачысціць кэш часта выкарыстоўваных прадуктаў? Гэта выдаліць усю гісторыю выкарыстання.';

  @override
  String get cacheCleared => 'Кэш ачышчаны';

  @override
  String get appVersion => 'Версія праграмы';

  @override
  String get appVersionNumber => 'PureCal v1.0.0';

  @override
  String get appDescription =>
      'Праграма для вядзення дзённіка харчавання, адсочвання штодзённага рацыёну і дасягнення вашых мэтаў.';

  @override
  String get openFoodFacts => 'Open Food Facts';

  @override
  String get openFoodFactsAttribution =>
      'Дадзеныя пра прадукты прадастаўлены Open Food Facts';

  @override
  String get openFoodFactsDescription =>
      'Гэтая праграма выкарыстоўвае дадзеныя пра прадукты з Open Food Facts, бясплатнай і адкрытай базы дадзеных прадуктаў харчавання з усяго свету.';

  @override
  String get today => 'Сёння';

  @override
  String get week => 'Тыдзень';

  @override
  String get loadingCharts => 'Загрузка графікаў...';

  @override
  String get weeklyCalorieTrend => 'Штотыднёвая тэндэнцыя калорый';

  @override
  String get last7Days => 'Апошнія 7 дзён';

  @override
  String get todaysMacroBreakdown => 'Размеркаванне макранутрыентаў сёння';

  @override
  String get noMacroDataForToday => 'Няма дадзеных пра макранутрыенты за сёння';

  @override
  String get addSomeFoodToSeeMacros =>
      'Дадайце ежу, каб убачыць размеркаванне макранутрыентаў';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'элементаў',
      few: 'элементы',
      one: 'элемент',
    );
    return '$count $_temp0';
  }

  @override
  String get pointCameraAtBarcode =>
      'Накіруйце камеру на штрых-код для сканавання';

  @override
  String get error => 'Памылка';

  @override
  String get unknownError => 'Адбылася невядомая памылка';

  @override
  String get mealType => 'Тып прыёму ежы';

  @override
  String get notes => 'Нататкі';

  @override
  String get image => 'Выява';

  @override
  String get changeImage => 'Змяніць выяву';

  @override
  String get addImage => 'Дадаць выяву';

  @override
  String failedToLoadChartData(String error) {
    return 'Не ўдалося загрузіць дадзеныя графіка: $error';
  }

  @override
  String get noDataAvailable => 'Няма даступных дадзеных';

  @override
  String get weeklyMacroTrends => 'Штотыднёвыя тэндэнцыі макранутрыентаў';

  @override
  String get proteinFatCarbsGrams => 'Бялкі, тлушчы і вугляводы (грамы)';

  @override
  String errorPickingImage(String error) {
    return 'Памылка выбару выявы: $error';
  }

  @override
  String get selectImageSource => 'Выбраць крыніцу выявы';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерэя';

  @override
  String errorSavingProduct(String error) {
    return 'Памылка захавання прадукту: $error';
  }

  @override
  String get addPhoto => 'Дадаць фота';

  @override
  String get caloriesKcalRequired => 'Калорыі (ккал) *';

  @override
  String get proteinGramsRequired => 'Бялкі (г) *';

  @override
  String get fatGramsRequired => 'Тлушчы (г) *';

  @override
  String get carbohydratesGramsRequired => 'Вугляводы (г) *';

  @override
  String errorLoadingProducts(String error) {
    return 'Памылка загрузкі прадуктаў: $error';
  }

  @override
  String get productDeleted => 'Прадукт выдалены';

  @override
  String errorDeletingProduct(String error) {
    return 'Памылка выдалення прадукту: $error';
  }

  @override
  String kcalPer100g(String calories) {
    return '$calories ккал на 100г';
  }

  @override
  String get custom => 'Карыстальніцкі';

  @override
  String get slashSeparator => ' / ';

  @override
  String get goalsRecommendation =>
      'Гэтыя мэты з\'яўляюцца агульнымі рэкамендацыямі. Пракансультуйцеся з дыетолагам для атрымання індывідуальных рэкамендацый.';

  @override
  String failedToFetchProduct(String error) {
    return 'Не ўдалося атрымаць прадукт: $error';
  }

  @override
  String errorSearching(String error) {
    return 'Памылка пошуку: $error';
  }

  @override
  String get exportDiaryEntries => 'Экспарт запісаў дзённіка';

  @override
  String get exportDiaryEntriesDescription =>
      'Экспартаваць дзённік харчавання ў фармат CSV';

  @override
  String get exportingData => 'Экспарт дадзеных...';

  @override
  String get exportSuccess => 'Дзённік паспяхова экспартаваны!';

  @override
  String get exportError => 'Не ўдалося экспартаваць дадзеныя';

  @override
  String get noDataToExport => 'Няма запісаў дзённіка для экспарту';

  @override
  String get selectExportTimeframe => 'Выберыце перыяд экспарту';

  @override
  String get allTime => 'Увесь час';

  @override
  String get exportAllEntries => 'Экспартаваць усе запісы дзённіка';

  @override
  String get exportLast7Days => 'Экспартаваць запісы за апошнія 7 дзён';

  @override
  String get last30Days => 'Апошнія 30 дзён';

  @override
  String get exportLast30Days => 'Экспартаваць запісы за апошнія 30 дзён';

  @override
  String get productDetails => 'Дэталі прадукту';

  @override
  String get barcode => 'Штрых-код';

  @override
  String get basedOnOffProduct => 'На аснове прадукту OpenFoodFacts';
}
