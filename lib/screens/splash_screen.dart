import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.hasApiKey) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SettingsScreen(isFirstLaunch: true)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dummy logo container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.secondaryBlue],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.5),
                    blurRadius: 30,
                  )
                ],
              ),
              child: const Icon(Icons.mic, size: 60, color: Colors.white),
            ).animate().fade(duration: 800.ms).scale(curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: GoogleFonts.orbitron(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ).animate().fade(delay: 400.ms).slideY(),
            const SizedBox(height: 8),
            Text(
              AppStrings.tagline,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white70,
              ),
            ).animate().fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
