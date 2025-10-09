import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/splash_screen.dart';
import 'providers/settings_provider.dart';

class EduNovaApp extends StatelessWidget {
  const EduNovaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'EduNova',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Inter',
            brightness: settings.isHighContrast ? Brightness.dark : Brightness.light,
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                fontSize: settings.isLargeText ? 20 : 16,
              ),
              bodyMedium: TextStyle(
                fontSize: settings.isLargeText ? 18 : 14,
              ),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}