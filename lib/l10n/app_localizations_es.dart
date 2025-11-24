// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PureCal';

  @override
  String get homeTitle => 'PureCal';

  @override
  String get setGoals => 'Establecer Objetivos';

  @override
  String get viewCharts => 'Ver Gráficos';

  @override
  String get settings => 'Configuración';

  @override
  String get searchProducts => 'Buscar Productos';

  @override
  String get nutritionCharts => 'Gráficos de Nutrición';

  @override
  String get setYourGoals => 'Establece tus Objetivos';

  @override
  String get scanBarcode => 'Escanear Código de Barras';

  @override
  String get myProducts => 'Mis Productos';

  @override
  String get manageYourCustomProducts =>
      'Gestiona tus productos personalizados';

  @override
  String get quickAdd => 'Añadir Rápido';

  @override
  String get createProduct => 'Crear Producto';

  @override
  String get editProduct => 'Editar Producto';

  @override
  String get breakfast => 'Desayuno';

  @override
  String get lunch => 'Almuerzo';

  @override
  String get dinner => 'Cena';

  @override
  String get snacks => 'Aperitivos';

  @override
  String addToMeal(String mealType) {
    return 'Añadir a $mealType';
  }

  @override
  String scanForMeal(String mealType) {
    return 'Escanear para $mealType';
  }

  @override
  String noItemsForMeal(String mealType) {
    return 'No hay elementos para $mealType todavía';
  }

  @override
  String get summary => 'Resumen';

  @override
  String get calories => 'Calorías';

  @override
  String get protein => 'Proteína';

  @override
  String get fat => 'Grasa';

  @override
  String get carbs => 'Carbohidratos';

  @override
  String get carbohydrates => 'Carbohidratos';

  @override
  String macrosSummary(double protein, double fat, double carbs) {
    return '${protein}g P / ${fat}g G / ${carbs}g C';
  }

  @override
  String get kcal => 'kcal';

  @override
  String get grams => 'g';

  @override
  String get nutritionPer100g => 'Nutrición por 100g:';

  @override
  String get yourPortion => 'Tu porción:';

  @override
  String get goalAchievement => 'Logro de Objetivos';

  @override
  String get dailyNutritionGoals => 'Objetivos de Nutrición Diarios';

  @override
  String get setDailyTargets =>
      'Establece tus metas diarias de calorías y macronutrientes';

  @override
  String get actual => 'Real';

  @override
  String get goal => 'Objetivo';

  @override
  String get add => 'Añadir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get retry => 'Reintentar';

  @override
  String get ok => 'OK';

  @override
  String get clear => 'Limpiar';

  @override
  String get saveGoals => 'Guardar Objetivos';

  @override
  String get createProductButton => 'Crear Producto';

  @override
  String get updateProduct => 'Actualizar Producto';

  @override
  String get addToDiary => 'Añadir al Diario';

  @override
  String get tapPlusToAdd => 'Toca el botón + para añadir';

  @override
  String get searchProductsHint => 'Buscar productos...';

  @override
  String get searching => 'Buscando...';

  @override
  String get searchForProducts => 'Buscar productos por nombre';

  @override
  String get searchExamples => 'Prueba \"yogur\", \"pan\", \"manzana\"...';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get frequentlyUsed => 'Usados Frecuentemente';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get noCustomProductsYet => 'No hay productos personalizados todavía';

  @override
  String get productName => 'Nombre del Producto';

  @override
  String get productNameRequired => 'Nombre del Producto *';

  @override
  String get brand => 'Marca';

  @override
  String get barcodeOptional => 'Código de Barras (opcional)';

  @override
  String get portionSize => 'Tamaño de la Porción';

  @override
  String get gramsUnit => 'gramos';

  @override
  String get typicalServingSize => 'Tamaño de Porción Típico (g)';

  @override
  String get pleaseEnterProductName =>
      'Por favor ingresa un nombre de producto';

  @override
  String get pleaseEnterValidNumber => 'Por favor ingresa un número válido';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get valueMustBeNonNegative => 'El valor debe ser no negativo';

  @override
  String get leaveEmptyForHomemade => 'Dejar vacío para artículos caseros';

  @override
  String get additionalInformation =>
      'Información adicional sobre este producto';

  @override
  String get deleteProduct => 'Eliminar Producto';

  @override
  String deleteProductConfirmation(String productName) {
    return '¿Estás seguro de que quieres eliminar \"$productName\"?';
  }

  @override
  String get productNotFoundDialog => 'Producto No Encontrado';

  @override
  String noProductFoundWithBarcode(String barcode) {
    return 'No se encontró ningún producto con el código de barras: $barcode';
  }

  @override
  String get createCustomProductPrompt =>
      '¿Te gustaría crear un producto personalizado con este código de barras?';

  @override
  String get goalsUpdatedSuccessfully => 'Objetivos actualizados exitosamente';

  @override
  String addedProductToMeal(String productName, String mealType) {
    return 'Añadido $productName a $mealType';
  }

  @override
  String get productCreatedSuccessfully => 'Producto creado exitosamente';

  @override
  String get productUpdatedSuccessfully => 'Producto actualizado exitosamente';

  @override
  String errorLoadingProduct(String error) {
    return 'Error al cargar el producto: $error';
  }

  @override
  String get loadingProduct => 'Cargando producto...';

  @override
  String get appearance => 'Apariencia';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get manageDataExportImport => 'Exportar, importar y gestionar datos';

  @override
  String get dataExport => 'Exportación de Datos';

  @override
  String get dataImport => 'Importación de Datos';

  @override
  String get cacheManagement => 'Gestión de Caché';

  @override
  String get about => 'Acerca de';

  @override
  String get language => 'Idioma';

  @override
  String get chooseLanguage => 'Elegir Idioma';

  @override
  String get systemDefault => 'Predeterminado del Sistema';

  @override
  String get theme => 'Tema';

  @override
  String get chooseTheme => 'Elegir Tema';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get clearFrequentProductsCache =>
      'Limpiar Caché de Productos Frecuentes';

  @override
  String get clearFrequentProductsDescription =>
      'Eliminar todo el historial de productos usados frecuentemente';

  @override
  String get clearCache => 'Limpiar Caché';

  @override
  String get clearCacheConfirmation =>
      '¿Estás seguro de que quieres limpiar tu caché de productos frecuentes? Esto eliminará todo el historial de uso.';

  @override
  String get cacheCleared => 'Caché limpiado';

  @override
  String get appVersion => 'Versión de la App';

  @override
  String get loading => 'Cargando...';

  @override
  String get appDescription =>
      'Una aplicación de diario de alimentos para rastrear tu nutrición diaria y alcanzar tus objetivos.';

  @override
  String get openFoodFacts => 'Open Food Facts';

  @override
  String get openFoodFactsAttribution =>
      'Datos de productos proporcionados por Open Food Facts';

  @override
  String get openFoodFactsDescription =>
      'Esta aplicación utiliza datos de productos de Open Food Facts, una base de datos gratuita y abierta de productos alimenticios de todo el mundo.';

  @override
  String get today => 'Hoy';

  @override
  String get week => 'Semana';

  @override
  String get loadingCharts => 'Cargando gráficos...';

  @override
  String get weeklyCalorieTrend => 'Tendencia de Calorías Semanal';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get todaysMacroBreakdown => 'Desglose de Macros de Hoy';

  @override
  String get noMacroDataForToday => 'No hay datos de macros para hoy';

  @override
  String get addSomeFoodToSeeMacros =>
      'Añade algo de comida para ver tu desglose de macros';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'elementos',
      one: 'elemento',
    );
    return '$count $_temp0';
  }

  @override
  String get pointCameraAtBarcode =>
      'Apunta tu cámara a un código de barras para escanear';

  @override
  String get error => 'Error';

  @override
  String get unknownError => 'Ocurrió un error desconocido';

  @override
  String get mealType => 'Tipo de Comida';

  @override
  String get notes => 'Notas';

  @override
  String get image => 'Imagen';

  @override
  String get changeImage => 'Cambiar Imagen';

  @override
  String get addImage => 'Añadir Imagen';

  @override
  String failedToLoadChartData(String error) {
    return 'Error al cargar datos del gráfico: $error';
  }

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get weeklyMacroTrends => 'Tendencias de Macros Semanales';

  @override
  String get proteinFatCarbsGrams => 'Proteína, Grasa y Carbohidratos (gramos)';

  @override
  String errorPickingImage(String error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String get selectImageSource => 'Seleccionar Fuente de Imagen';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String errorSavingProduct(String error) {
    return 'Error al guardar producto: $error';
  }

  @override
  String get addPhoto => 'Añadir Foto';

  @override
  String get caloriesKcalRequired => 'Calorías (kcal) *';

  @override
  String get proteinGramsRequired => 'Proteína (g) *';

  @override
  String get fatGramsRequired => 'Grasa (g) *';

  @override
  String get carbohydratesGramsRequired => 'Carbohidratos (g) *';

  @override
  String errorLoadingProducts(String error) {
    return 'Error al cargar productos: $error';
  }

  @override
  String get productDeleted => 'Producto eliminado';

  @override
  String errorDeletingProduct(String error) {
    return 'Error al eliminar producto: $error';
  }

  @override
  String kcalPer100g(String calories) {
    return '$calories kcal por 100g';
  }

  @override
  String get custom => 'Personalizado';

  @override
  String get slashSeparator => ' / ';

  @override
  String get goalsRecommendation =>
      'Estos objetivos son recomendaciones generales. Consulta a un nutricionista para obtener asesoramiento personalizado.';

  @override
  String failedToFetchProduct(String error) {
    return 'Error al obtener producto: $error';
  }

  @override
  String errorSearching(String error) {
    return 'Error al buscar: $error';
  }

  @override
  String get exportDiaryEntries => 'Exportar Entradas del Diario';

  @override
  String get exportDiaryEntriesDescription =>
      'Exporta tu diario de alimentos a formato CSV';

  @override
  String get exportingData => 'Exportando datos...';

  @override
  String get exportSuccess => '¡Diario exportado exitosamente!';

  @override
  String get exportError => 'Error al exportar datos';

  @override
  String get noDataToExport => 'No hay entradas del diario para exportar';

  @override
  String get selectExportTimeframe => 'Seleccionar Período de Exportación';

  @override
  String get allTime => 'Todo el Tiempo';

  @override
  String get exportAllEntries => 'Exportar todas las entradas del diario';

  @override
  String get exportLast7Days => 'Exportar entradas de los últimos 7 días';

  @override
  String get last30Days => 'Últimos 30 Días';

  @override
  String get exportLast30Days => 'Exportar entradas de los últimos 30 días';

  @override
  String get exportProducts => 'Exportar Productos';

  @override
  String get exportProductsDescription =>
      'Exporta tus productos locales a formato JSON';

  @override
  String get exportProductsSuccess => '¡Productos exportados exitosamente!';

  @override
  String get noProductsToExport => 'No hay productos locales para exportar';

  @override
  String get importProducts => 'Importar Productos';

  @override
  String get importProductsDescription =>
      'Importar productos desde un archivo JSON';

  @override
  String get importingProducts => 'Importando Productos';

  @override
  String importingProductsProgress(int current, int total) {
    return 'Importando $current de $total productos...';
  }

  @override
  String get importComplete => 'Importación Completa';

  @override
  String get importError => 'Error al importar';

  @override
  String get imported => 'Importados';

  @override
  String get skipped => 'Omitidos';

  @override
  String get errors => 'Errores';

  @override
  String get errorDetails => 'Detalles del Error';

  @override
  String get close => 'Cerrar';

  @override
  String get productConflictTitle => 'Conflicto de Producto';

  @override
  String get productConflictMessage =>
      'Ya existe un producto con este código de barras. ¿Qué deseas hacer?';

  @override
  String get existingProduct => 'Producto existente';

  @override
  String get importedProduct => 'Producto importado';

  @override
  String get keepExisting => 'Mantener Existente';

  @override
  String get replaceWithImport => 'Reemplazar';

  @override
  String get keepAllRemaining => 'Mantener Todos los Restantes';

  @override
  String get replaceAllRemaining => 'Reemplazar Todos los Restantes';

  @override
  String get productDetails => 'Detalles del Producto';

  @override
  String get barcode => 'Código de Barras';

  @override
  String get basedOnOffProduct => 'Basado en el producto de OpenFoodFacts';

  @override
  String get fromUsdaDatabase => 'De la Base de Datos de USDA';
}
