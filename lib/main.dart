import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/diary_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        home: const HomeScreen(),
      ),
    );
  }
}
