import 'package:device_apps/device_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class AppLauncherService {
  Future<bool> openApp(String appName) async {
    final normalized = appName.toLowerCase().trim();

    // 1. Try known apps map first
    final packageId = KnownApps.packages[normalized];
    if (packageId != null) {
      return await _launchPackage(packageId);
    }

    // 2. Fuzzy match against installed apps
    final apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    Application? bestMatch;
    int bestScore = 0;

    for (final app in apps) {
      final appLabel = app.appName.toLowerCase();
      final score = _fuzzyScore(normalized, appLabel);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = app;
      }
    }

    if (bestMatch != null && bestScore > 60) {
      return await DeviceApps.openApp(bestMatch.packageName);
    }

    return false;
  }

  int _fuzzyScore(String query, String target) {
    if (target == query) return 100;
    if (target.contains(query)) return 90;
    if (query.contains(target)) return 80;

    // Character overlap scoring
    int matches = 0;
    for (int i = 0; i < query.length; i++) {
      if (target.contains(query[i])) matches++;
    }
    return ((matches / query.length) * 70).round();
  }

  Future<bool> _launchPackage(String packageOrIntent) async {
    try {
      if (packageOrIntent.contains('.')) {
        return await DeviceApps.openApp(packageOrIntent);
      } else {
        // It's an intent action
        final intent = AndroidIntent(action: packageOrIntent);
        await intent.launch();
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}
