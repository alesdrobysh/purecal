// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'FoodieFit';

  @override
  String get homeTitle => 'FoodieFit';

  @override
  String get setGoals => 'Ustaw cele';

  @override
  String get viewCharts => 'Pokaż wykresy';

  @override
  String get settings => 'Ustawienia';

  @override
  String get searchProducts => 'Szukaj produktów';

  @override
  String get nutritionCharts => 'Wykresy odżywcze';

  @override
  String get setYourGoals => 'Ustaw swoje cele';

  @override
  String get scanBarcode => 'Skanuj kod kreskowy';

  @override
  String get myProducts => 'Moje produkty';

  @override
  String get manageYourCustomProducts => 'Zarządzaj swoimi własnymi produktami';

  @override
  String get quickAdd => 'Szybkie dodawanie';

  @override
  String get createProduct => 'Utwórz produkt';

  @override
  String get editProduct => 'Edytuj produkt';

  @override
  String get breakfast => 'Śniadanie';

  @override
  String get lunch => 'Obiad';

  @override
  String get dinner => 'Kolacja';

  @override
  String get snacks => 'Przekąski';

  @override
  String addToMeal(String mealType) {
    return 'Dodaj do $mealType';
  }

  @override
  String scanForMeal(String mealType) {
    return 'Skanuj dla $mealType';
  }

  @override
  String noItemsForMeal(String mealType) {
    return 'Brak elementów dla $mealType';
  }

  @override
  String get summary => 'Podsumowanie';

  @override
  String get calories => 'Kalorie';

  @override
  String get protein => 'Białko';

  @override
  String get fat => 'Tłuszcze';

  @override
  String get carbs => 'Węglowodany';

  @override
  String get carbohydrates => 'Węglowodany';

  @override
  String macrosSummary(double protein, double fat, double carbs) {
    return '${protein}g B / ${fat}g T / ${carbs}g W';
  }

  @override
  String get kcal => 'kcal';

  @override
  String get grams => 'g';

  @override
  String get nutritionPer100g => 'Wartości odżywcze na 100g:';

  @override
  String get yourPortion => 'Twoja porcja:';

  @override
  String get goalAchievement => 'Osiągnięcie celów';

  @override
  String get dailyNutritionGoals => 'Dzienne cele żywieniowe';

  @override
  String get setDailyTargets =>
      'Ustaw swoje dzienne cele dotyczące kalorii i makroskładników';

  @override
  String get actual => 'Rzeczywiste';

  @override
  String get goal => 'Cel';

  @override
  String get add => 'Dodaj';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get delete => 'Usuń';

  @override
  String get edit => 'Edytuj';

  @override
  String get retry => 'Ponów';

  @override
  String get ok => 'OK';

  @override
  String get clear => 'Wyczyść';

  @override
  String get saveGoals => 'Zapisz cele';

  @override
  String get createProductButton => 'Utwórz produkt';

  @override
  String get updateProduct => 'Zaktualizuj produkt';

  @override
  String get addToDiary => 'Dodaj do dziennika';

  @override
  String get tapPlusToAdd => 'Dotknij przycisku + aby dodać';

  @override
  String get searchProductsHint => 'Szukaj produktów...';

  @override
  String get searching => 'Szukanie...';

  @override
  String get searchForProducts => 'Szukaj produktów po nazwie';

  @override
  String get searchExamples => 'Spróbuj \"jogurt\", \"chleb\", \"jabłko\"...';

  @override
  String get noProductsFound => 'Nie znaleziono produktów';

  @override
  String get frequentlyUsed => 'Często używane';

  @override
  String get productNotFound => 'Produkt nie znaleziony';

  @override
  String get noCustomProductsYet => 'Brak jeszcze własnych produktów';

  @override
  String get productName => 'Nazwa produktu';

  @override
  String get productNameRequired => 'Nazwa produktu *';

  @override
  String get brand => 'Marka';

  @override
  String get barcodeOptional => 'Kod kreskowy (opcjonalnie)';

  @override
  String get portionSize => 'Rozmiar porcji';

  @override
  String get gramsUnit => 'gramy';

  @override
  String get typicalServingSize => 'Typowy rozmiar porcji (g)';

  @override
  String get pleaseEnterProductName => 'Proszę podać nazwę produktu';

  @override
  String get pleaseEnterValidNumber => 'Proszę podać prawidłową liczbę';

  @override
  String get fieldRequired => 'To pole jest wymagane';

  @override
  String get valueMustBeNonNegative => 'Wartość musi być nieujemna';

  @override
  String get leaveEmptyForHomemade => 'Pozostaw puste dla produktów domowych';

  @override
  String get additionalInformation => 'Dodatkowe informacje o tym produkcie';

  @override
  String get deleteProduct => 'Usuń produkt';

  @override
  String deleteProductConfirmation(String productName) {
    return 'Czy na pewno chcesz usunąć \"$productName\"?';
  }

  @override
  String get productNotFoundDialog => 'Produkt nie znaleziony';

  @override
  String noProductFoundWithBarcode(String barcode) {
    return 'Nie znaleziono produktu z kodem kreskowym: $barcode';
  }

  @override
  String get createCustomProductPrompt =>
      'Czy chcesz utworzyć własny produkt z tym kodem kreskowym?';

  @override
  String get goalsUpdatedSuccessfully =>
      'Cele zostały pomyślnie zaktualizowane';

  @override
  String addedProductToMeal(String productName, String mealType) {
    return 'Dodano $productName do $mealType';
  }

  @override
  String get productCreatedSuccessfully => 'Produkt został pomyślnie utworzony';

  @override
  String get productUpdatedSuccessfully =>
      'Produkt został pomyślnie zaktualizowany';

  @override
  String errorLoadingProduct(String error) {
    return 'Błąd ładowania produktu: $error';
  }

  @override
  String get loadingProduct => 'Ładowanie produktu...';

  @override
  String get appearance => 'Wygląd';

  @override
  String get dataManagement => 'Zarządzanie danymi';

  @override
  String get about => 'O aplikacji';

  @override
  String get language => 'Język';

  @override
  String get chooseLanguage => 'Wybierz język';

  @override
  String get systemDefault => 'Domyślny systemu';

  @override
  String get theme => 'Motyw';

  @override
  String get chooseTheme => 'Wybierz motyw';

  @override
  String get lightTheme => 'Jasny motyw';

  @override
  String get darkTheme => 'Ciemny motyw';

  @override
  String get clearFrequentProductsCache =>
      'Wyczyść pamięć podręczną często używanych produktów';

  @override
  String get clearFrequentProductsDescription =>
      'Usuń całą historię często używanych produktów';

  @override
  String get clearCache => 'Wyczyść pamięć podręczną';

  @override
  String get clearCacheConfirmation =>
      'Czy na pewno chcesz wyczyścić pamięć podręczną często używanych produktów? Spowoduje to usunięcie całej historii użycia.';

  @override
  String get cacheCleared => 'Pamięć podręczna wyczyszczona';

  @override
  String get appVersion => 'Wersja aplikacji';

  @override
  String get appVersionNumber => 'FoodieFit v1.0.0';

  @override
  String get appDescription =>
      'Aplikacja dziennika żywieniowego do śledzenia codziennego odżywiania i osiągania celów.';

  @override
  String get openFoodFacts => 'Open Food Facts';

  @override
  String get openFoodFactsAttribution =>
      'Dane o produktach dostarczone przez Open Food Facts';

  @override
  String get openFoodFactsDescription =>
      'Ta aplikacja wykorzystuje dane o produktach z Open Food Facts, darmowej i otwartej bazy danych produktów spożywczych z całego świata.';

  @override
  String get today => 'Dzisiaj';

  @override
  String get week => 'Tydzień';

  @override
  String get loadingCharts => 'Ładowanie wykresów...';

  @override
  String get weeklyCalorieTrend => 'Tygodniowy trend kalorii';

  @override
  String get last7Days => 'Ostatnie 7 dni';

  @override
  String get todaysMacroBreakdown => 'Dzisiejszy rozkład makroskładników';

  @override
  String get noMacroDataForToday => 'Brak danych o makroskładnikach na dzisiaj';

  @override
  String get addSomeFoodToSeeMacros =>
      'Dodaj jedzenie, aby zobaczyć rozkład makroskładników';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'elementów',
      few: 'elementy',
      one: 'element',
    );
    return '$count $_temp0';
  }

  @override
  String get pointCameraAtBarcode =>
      'Skieruj aparat na kod kreskowy, aby zeskanować';

  @override
  String get error => 'Błąd';

  @override
  String get unknownError => 'Wystąpił nieznany błąd';

  @override
  String get mealType => 'Typ posiłku';

  @override
  String get notes => 'Notatki';

  @override
  String get image => 'Obraz';

  @override
  String get changeImage => 'Zmień obraz';

  @override
  String get addImage => 'Dodaj obraz';

  @override
  String failedToLoadChartData(String error) {
    return 'Nie udało się załadować danych wykresu: $error';
  }

  @override
  String get noDataAvailable => 'Brak dostępnych danych';

  @override
  String get weeklyMacroTrends => 'Tygodniowe trendy makroskładników';

  @override
  String get proteinFatCarbsGrams => 'Białko, tłuszcze i węglowodany (gramy)';

  @override
  String errorPickingImage(String error) {
    return 'Błąd wybierania obrazu: $error';
  }

  @override
  String get selectImageSource => 'Wybierz źródło obrazu';

  @override
  String get camera => 'Aparat';

  @override
  String get gallery => 'Galeria';

  @override
  String errorSavingProduct(String error) {
    return 'Błąd zapisywania produktu: $error';
  }

  @override
  String get addPhoto => 'Dodaj zdjęcie';

  @override
  String get caloriesKcalRequired => 'Kalorie (kcal) *';

  @override
  String get proteinGramsRequired => 'Białko (g) *';

  @override
  String get fatGramsRequired => 'Tłuszcze (g) *';

  @override
  String get carbohydratesGramsRequired => 'Węglowodany (g) *';

  @override
  String errorLoadingProducts(String error) {
    return 'Błąd ładowania produktów: $error';
  }

  @override
  String get productDeleted => 'Produkt usunięty';

  @override
  String errorDeletingProduct(String error) {
    return 'Błąd usuwania produktu: $error';
  }

  @override
  String kcalPer100g(String calories) {
    return '$calories kcal na 100g';
  }

  @override
  String get custom => 'Własny';

  @override
  String get slashSeparator => ' / ';

  @override
  String get goalsRecommendation =>
      'Te cele są ogólnymi zaleceniami. Skonsultuj się z dietetykiem, aby uzyskać spersonalizowane porady.';

  @override
  String failedToFetchProduct(String error) {
    return 'Nie udało się pobrać produktu: $error';
  }

  @override
  String errorSearching(String error) {
    return 'Błąd wyszukiwania: $error';
  }
}
