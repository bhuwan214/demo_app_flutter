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
		return MaterialApp(
			title: 'Demo App',
			debugShowCheckedModeBanner: false,
			theme: ThemeData(
				brightness: Brightness.light,
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
				useMaterial3: true,
			),
			darkTheme: ThemeData(
				brightness: Brightness.dark,
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
				useMaterial3: true,
			),
			themeMode: _themeMode,
      routes:{
        '/contact_us':(context)=> const ContactPage(),
      },
    
			home: HomePage(
				themeMode: _themeMode,
				onThemeChanged: _updateThemeMode,
			),
     
		);
	}
}
