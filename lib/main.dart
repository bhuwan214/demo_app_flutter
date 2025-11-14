import 'package:flutter/material.dart';
import 'home.dart';
// import'buttonbar.dart';

import './pages/contact_us.dart';
import './login_page.dart';
import 'signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
    data: _themeMode == ThemeMode.dark
    ? ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.deepOrangeAccent,
          surface: Color.fromARGB(255, 146, 142, 142),
          background: Color(0xFF121212),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white70,
          onBackground: Colors.white70,
        ),
        useMaterial3: true,
      )
    : ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Colors.orange,
          secondary: Colors.deepOrangeAccent,
          surface: Colors.white,
          background: Color(0xFFF7F7F7),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
        ),
        useMaterial3: true,
      ),

      duration: const Duration(milliseconds: 500), // ← Animation duration
      curve: Curves.easeInOut, // ← Animation curve
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Demo App',
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context),


          routes: {
        '/home': (context) => HomePage(
              themeMode: _themeMode,
              onThemeChanged: _updateThemeMode,
            ),
        '/login': (context) => MyLogin(
              themeMode: _themeMode,
              onThemeChanged: _updateThemeMode,
            ),
        '/signup': (context) => SignupPage(
              themeMode: _themeMode,
              onThemeChanged: _updateThemeMode,
            ),
        '/contact_us': (context) => const ContactPage(),
      },

      // Initial Route
      home: MyLogin(
        themeMode: _themeMode,
        onThemeChanged: _updateThemeMode,
      ),
        ),
      ),
    );
  }
}
