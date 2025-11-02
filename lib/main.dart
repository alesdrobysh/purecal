import 'package:foodiefit/services/off_api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/diary_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OFFApiService.initialize();
  runApp(const FoodieApp());
}

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DiaryProvider()..initialize(),
      child: MaterialApp(
        title: 'FoodieFit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
          ),
        ),
        builder: (context, child) {
          return SafeArea(
            top: false, // Set to true if you want to avoid notch overlap too
            bottom: true, // Avoids overlap with navigation bar
            child: child!,
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}
