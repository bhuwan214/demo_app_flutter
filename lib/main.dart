import 'package:demo_app/pages/password_reset.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home.dart';
// import'buttonbar.dart';

import './pages/contact_us.dart';
import './login_page.dart';
import 'signup_page.dart';
import 'package:demo_app/pages/add_addres.dart';
import 'package:demo_app/pages/order_history.dart';
import 'package:demo_app/pages/forgot_password.dart';
import 'package:demo_app/pages/reset_password_new.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          primaryContainer: Color(0xFF2C2C2C),
          onPrimaryContainer: Colors.white,
          surfaceContainerHighest: Color(0xFF2C2C2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      )
    : ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Colors.orange,
          secondary: Colors.deepOrangeAccent,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          primaryContainer: Color(0xFFFFE0B2),
          onPrimaryContainer: Colors.black87,
          surfaceContainerHighest: Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        cardColor: Colors.white,
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
        '/add_address': (context) => const AddAddressPage(),
        '/add-address': (context) => const AddAddressPage(),
        '/password_reset': (context) => PasswordResetPage(),
        '/order-history': (context) => const OrderHistoryPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/reset-password-new') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ResetPasswordNewPage(
              mobileNumber: args['mobile_no']!,
              otp: args['otp']!,
              token: args['token'],
            ),
          );
        }
        return null;
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
