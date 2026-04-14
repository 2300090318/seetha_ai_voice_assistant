import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'providers/settings_provider.dart';

class SeethApp extends StatelessWidget {
  const SeethApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'SEETHA',
          debugShowCheckedModeBanner: false,
          themeMode: settings.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: const SplashScreen(),
        );
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0a0a0a),
      cardColor: const Color(0xFF1a1a2e),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7c3aed),
        secondary: Color(0xFF3b82f6),
        surface: Color(0xFF1a1a2e),
        background: Color(0xFF0a0a0a),
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0a0a0a),
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          color: const Color(0xFF7c3aed),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7c3aed),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xFF7c3aed),
        thumbColor: Color(0xFF7c3aed),
        inactiveTrackColor: Color(0xFF2d2d2d),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? const Color(0xFF7c3aed)
              : Colors.grey,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? const Color(0xFF7c3aed).withOpacity(0.4)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF1a1a2e),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7c3aed),
        secondary: Color(0xFF3b82f6),
        surface: Colors.white,
        background: Color(0xFFF5F5F5),
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          color: const Color(0xFF7c3aed),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0a0a0a)),
      ),
    );
  }
}
