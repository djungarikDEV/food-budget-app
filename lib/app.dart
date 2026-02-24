import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_budget_app/data/app_config.dart';
import 'package:food_budget_app/screens/home_screen.dart';
import 'package:food_budget_app/screens/splash_screen.dart';
import 'package:food_budget_app/screens/login_screen.dart';

class FoodBudgetApp extends StatefulWidget {
  const FoodBudgetApp({super.key});

  static FoodBudgetAppState of(BuildContext context) =>
      context.findAncestorStateOfType<FoodBudgetAppState>()!;

  @override
  State<FoodBudgetApp> createState() => FoodBudgetAppState();
}

class FoodBudgetAppState extends State<FoodBudgetApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String _locale = 'hu';
  bool _showSplash = true;
  bool? _isLoggedIn;

  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await AppConfig.isLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

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
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isLoggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isLoggedIn == false) {
      return LoginScreen(
        onLogin: () => setState(() {
          _isLoggedIn = true;
          _showSplash = true;
        }),
      );
    }
    if (_showSplash) {
      return SplashScreen(
          onDone: () => setState(() => _showSplash = false));
    }
    return HomeScreen(locale: _locale);
  }
}
