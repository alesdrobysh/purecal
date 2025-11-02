import 'package:foodiefit/config/theme.dart';
import 'package:foodiefit/services/off_api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/diary_provider.dart';
import 'services/settings_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OFFApiService.initialize();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadInitialTheme(); // New method to load theme
  runApp(FoodieApp(settingsProvider: settingsProvider));
}

class FoodieApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  const FoodieApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => DiaryProvider()..initialize()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'FoodieFit',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
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
