import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_budget_app/screens/home_screen.dart';
import 'package:food_budget_app/screens/splash_screen.dart';

class FoodBudgetApp extends StatefulWidget {
  const FoodBudgetApp({super.key});

  static FoodBudgetAppState of(BuildContext context) =>
      context.findAncestorStateOfType<FoodBudgetAppState>()!;

  @override
  State<FoodBudgetApp> createState() => FoodBudgetAppState();
}

class FoodBudgetAppState extends State<FoodBudgetApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  String _locale = 'hu';
  bool _showSplash = true;

  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void setLocale(String locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Budget',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: _showSplash
          ? SplashScreen(onDone: () => setState(() => _showSplash = false))
          : HomeScreen(locale: _locale),
    );
  }
}
