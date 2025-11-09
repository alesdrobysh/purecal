import 'package:foodiefit/config/theme.dart';
import 'package:foodiefit/services/off_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/diary_provider.dart';
import 'services/settings_provider.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'features/ai_chat/services/chat_provider.dart';
import 'features/ai_chat/services/gemma_service.dart';
import 'features/ai_chat/services/nutrition_prompt_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  OFFApiService.initialize();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadInitialSettings();

  // Initialize database for AI chat
  final database = await DatabaseService().database;

  runApp(FoodieApp(
    settingsProvider: settingsProvider,
    database: database,
  ));
}

class FoodieApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final dynamic database;
  const FoodieApp({
    super.key,
    required this.settingsProvider,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => DiaryProvider()..initialize()),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            gemmaService: GemmaService(),
            promptBuilder: NutritionPromptBuilder(),
            database: database,
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
      title: 'PureCal',
      theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            locale: settingsProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('es'),
              Locale('ru'),
              Locale('pl'),
              Locale('be'),
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) {
                return supportedLocales.first;
              }
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            builder: (context, child) {
              return SafeArea(
                top: false,
                bottom: true,
                child: child!,
              );
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
