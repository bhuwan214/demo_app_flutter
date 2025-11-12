import 'package:flutter/material.dart';
import 'home.dart';
// import'buttonbar.dart';
import './pages/contact_us.dart';

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
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 247, 165, 42),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            )
          : ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
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
            '/contact_us': (context) => const ContactPage(),
            // '/delivery_location':(context)=>const
          },
          home: HomePage(
            themeMode: _themeMode,
            onThemeChanged: _updateThemeMode,
          ),
        ),
      ),
    );
  }
}
