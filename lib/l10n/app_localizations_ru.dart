// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'PureCal';

  @override
  String get homeTitle => 'PureCal';

  @override
  String get setGoals => 'Установить цели';

  @override
  String get viewCharts => 'Посмотреть графики';

  @override
  String get settings => 'Настройки';

  @override
  String get searchProducts => 'Поиск продуктов';

  @override
  String get nutritionCharts => 'Графики питания';

  @override
  String get setYourGoals => 'Установите свои цели';

  @override
  String get scanBarcode => 'Сканировать штрихкод';

  @override
  String get myProducts => 'Мои продукты';

  @override
  String get manageYourCustomProducts =>
      'Управление вашими пользовательскими продуктами';

  @override
  String get quickAdd => 'Быстрое добавление';

  @override
  String get createProduct => 'Создать продукт';

  @override
  String get editProduct => 'Редактировать продукт';

  @override
  String get breakfast => 'Завтрак';

  @override
  String get lunch => 'Обед';

  @override
  String get dinner => 'Ужин';

  @override
  String get snacks => 'Перекусы';

  @override
  String addToMeal(String mealType) {
    return 'Добавить к $mealType';
  }

  @override
  String scanForMeal(String mealType) {
    return 'Сканировать для $mealType';
  }

  @override
  String noItemsForMeal(String mealType) {
    return 'Пока нет элементов для $mealType';
  }

  @override
  String get summary => 'Сводка';

  @override
  String get calories => 'Калории';

  @override
  String get protein => 'Белки';

  @override
  String get fat => 'Жиры';

  @override
  String get carbs => 'Углеводы';

  @override
  String get carbohydrates => 'Углеводы';

  @override
  String macrosSummary(double protein, double fat, double carbs) {
    return '$proteinг Б / $fatг Ж / $carbsг У';
  }

  @override
  String get kcal => 'ккал';

  @override
  String get grams => 'г';

  @override
  String get nutritionPer100g => 'Питание на 100г:';

  @override
  String get yourPortion => 'Ваша порция:';

  @override
  String get goalAchievement => 'Достижение целей';

  @override
  String get dailyNutritionGoals => 'Ежедневные цели питания';

  @override
  String get setDailyTargets =>
      'Установите ежедневные цели по калориям и макронутриентам';

  @override
  String get actual => 'Фактически';

  @override
  String get goal => 'Цель';

  @override
  String get add => 'Добавить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get retry => 'Повторить';

  @override
  String get ok => 'ОК';

  @override
  String get clear => 'Очистить';

  @override
  String get saveGoals => 'Сохранить цели';

  @override
  String get createProductButton => 'Создать продукт';

  @override
  String get updateProduct => 'Обновить продукт';

  @override
  String get addToDiary => 'Добавить в дневник';

  @override
  String get tapPlusToAdd => 'Нажмите кнопку + для добавления';

  @override
  String get searchProductsHint => 'Поиск продуктов...';

  @override
  String get searching => 'Поиск...';

  @override
  String get searchForProducts => 'Поиск продуктов по названию';

  @override
  String get searchExamples => 'Попробуйте \"йогурт\", \"хлеб\", \"яблоко\"...';

  @override
  String get noProductsFound => 'Продукты не найдены';

  @override
  String get frequentlyUsed => 'Часто используемые';

  @override
  String get productNotFound => 'Продукт не найден';

  @override
  String get noCustomProductsYet => 'Пока нет пользовательских продуктов';

  @override
  String get productName => 'Название продукта';

  @override
  String get productNameRequired => 'Название продукта *';

  @override
  String get brand => 'Бренд';

  @override
  String get barcodeOptional => 'Штрихкод (необязательно)';

  @override
  String get portionSize => 'Размер порции';

  @override
  String get gramsUnit => 'граммы';

  @override
  String get typicalServingSize => 'Типичный размер порции (г)';

  @override
  String get pleaseEnterProductName => 'Пожалуйста, введите название продукта';

  @override
  String get pleaseEnterValidNumber => 'Пожалуйста, введите допустимое число';

  @override
  String get fieldRequired => 'Это поле обязательно';

  @override
  String get valueMustBeNonNegative => 'Значение должно быть неотрицательным';

  @override
  String get leaveEmptyForHomemade => 'Оставьте пустым для домашних продуктов';

  @override
  String get additionalInformation =>
      'Дополнительная информация об этом продукте';

  @override
  String get deleteProduct => 'Удалить продукт';

  @override
  String deleteProductConfirmation(String productName) {
    return 'Вы уверены, что хотите удалить \"$productName\"?';
  }

  @override
  String get productNotFoundDialog => 'Продукт не найден';

  @override
  String noProductFoundWithBarcode(String barcode) {
    return 'Продукт со штрихкодом $barcode не найден';
  }

  @override
  String get createCustomProductPrompt =>
      'Хотите создать пользовательский продукт с этим штрихкодом?';

  @override
  String get goalsUpdatedSuccessfully => 'Цели успешно обновлены';

  @override
  String addedProductToMeal(String productName, String mealType) {
    return 'Добавлен $productName к $mealType';
  }

  @override
  String get productCreatedSuccessfully => 'Продукт успешно создан';

  @override
  String get productUpdatedSuccessfully => 'Продукт успешно обновлен';

  @override
  String errorLoadingProduct(String error) {
    return 'Ошибка загрузки продукта: $error';
  }

  @override
  String get loadingProduct => 'Загрузка продукта...';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get dataManagement => 'Управление данными';

  @override
  String get about => 'О приложении';

  @override
  String get language => 'Язык';

  @override
  String get chooseLanguage => 'Выбрать язык';

  @override
  String get systemDefault => 'Системный по умолчанию';

  @override
  String get theme => 'Тема';

  @override
  String get chooseTheme => 'Выбрать тему';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get darkTheme => 'Темная тема';

  @override
  String get clearFrequentProductsCache =>
      'Очистить кэш часто используемых продуктов';

  @override
  String get clearFrequentProductsDescription =>
      'Удалить всю историю часто используемых продуктов';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get clearCacheConfirmation =>
      'Вы уверены, что хотите очистить кэш часто используемых продуктов? Это удалит всю историю использования.';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get appVersionNumber => 'PureCal v1.0.0';

  @override
  String get appDescription =>
      'Приложение для ведения дневника питания, отслеживания ежедневного рациона и достижения ваших целей.';

  @override
  String get openFoodFacts => 'Open Food Facts';

  @override
  String get openFoodFactsAttribution =>
      'Данные о продуктах предоставлены Open Food Facts';

  @override
  String get openFoodFactsDescription =>
      'Это приложение использует данные о продуктах из Open Food Facts, бесплатной и открытой базы данных продуктов питания со всего мира.';

  @override
  String get today => 'Сегодня';

  @override
  String get week => 'Неделя';

  @override
  String get loadingCharts => 'Загрузка графиков...';

  @override
  String get weeklyCalorieTrend => 'Еженедельная тенденция калорий';

  @override
  String get last7Days => 'Последние 7 дней';

  @override
  String get todaysMacroBreakdown => 'Распределение макронутриентов сегодня';

  @override
  String get noMacroDataForToday => 'Нет данных о макронутриентах за сегодня';

  @override
  String get addSomeFoodToSeeMacros =>
      'Добавьте еду, чтобы увидеть распределение макронутриентов';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'элементов',
      few: 'элемента',
      one: 'элемент',
    );
    return '$count $_temp0';
  }

  @override
  String get pointCameraAtBarcode =>
      'Наведите камеру на штрихкод для сканирования';

  @override
  String get error => 'Ошибка';

  @override
  String get unknownError => 'Произошла неизвестная ошибка';

  @override
  String get mealType => 'Тип приёма пищи';

  @override
  String get notes => 'Заметки';

  @override
  String get image => 'Изображение';

  @override
  String get changeImage => 'Изменить изображение';

  @override
  String get addImage => 'Добавить изображение';

  @override
  String failedToLoadChartData(String error) {
    return 'Не удалось загрузить данные графика: $error';
  }

  @override
  String get noDataAvailable => 'Нет доступных данных';

  @override
  String get weeklyMacroTrends => 'Еженедельные тенденции макронутриентов';

  @override
  String get proteinFatCarbsGrams => 'Белки, жиры и углеводы (граммы)';

  @override
  String errorPickingImage(String error) {
    return 'Ошибка выбора изображения: $error';
  }

  @override
  String get selectImageSource => 'Выбрать источник изображения';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String errorSavingProduct(String error) {
    return 'Ошибка сохранения продукта: $error';
  }

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get caloriesKcalRequired => 'Калории (ккал) *';

  @override
  String get proteinGramsRequired => 'Белки (г) *';

  @override
  String get fatGramsRequired => 'Жиры (г) *';

  @override
  String get carbohydratesGramsRequired => 'Углеводы (г) *';

  @override
  String errorLoadingProducts(String error) {
    return 'Ошибка загрузки продуктов: $error';
  }

  @override
  String get productDeleted => 'Продукт удалён';

  @override
  String errorDeletingProduct(String error) {
    return 'Ошибка удаления продукта: $error';
  }

  @override
  String kcalPer100g(String calories) {
    return '$calories ккал на 100г';
  }

  @override
  String get custom => 'Пользовательский';

  @override
  String get slashSeparator => ' / ';

  @override
  String get goalsRecommendation =>
      'Эти цели являются общими рекомендациями. Проконсультируйтесь с диетологом для получения индивидуальных рекомендаций.';

  @override
  String failedToFetchProduct(String error) {
    return 'Не удалось получить продукт: $error';
  }

  @override
  String errorSearching(String error) {
    return 'Ошибка поиска: $error';
  }

  @override
  String get exportDiaryEntries => 'Экспорт записей дневника';

  @override
  String get exportDiaryEntriesDescription =>
      'Экспортировать дневник питания в формат CSV';

  @override
  String get exportingData => 'Экспорт данных...';

  @override
  String get exportSuccess => 'Дневник успешно экспортирован!';

  @override
  String get exportError => 'Не удалось экспортировать данные';

  @override
  String get noDataToExport => 'Нет записей дневника для экспорта';

  @override
  String get selectExportTimeframe => 'Выберите период экспорта';

  @override
  String get allTime => 'Всё время';

  @override
  String get exportAllEntries => 'Экспортировать все записи дневника';

  @override
  String get exportLast7Days => 'Экспортировать записи за последние 7 дней';

  @override
  String get last30Days => 'Последние 30 дней';

  @override
  String get exportLast30Days => 'Экспортировать записи за последние 30 дней';

  @override
  String get productDetails => 'Product Details';

  @override
  String get barcode => 'Barcode';

  @override
  String get basedOnOffProduct => 'Based on OpenFoodFacts product';
}
