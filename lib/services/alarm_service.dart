import 'package:android_intent_plus/android_intent.dart';

class AlarmService {
  Future<bool> setAlarm(String timeStr, String message) async {
    // Basic time parsing: expects HH:mm or H:mm PM
    try {
      int hour = 0;
      int minute = 0;
      
      final cleaned = timeStr.trim().toLowerCase();
      final hasAm = cleaned.contains('am');
      final hasPm = cleaned.contains('pm');
      final timeParts = cleaned.replaceAll(RegExp(r'[a-z]'), '').trim().split(':');

      if (timeParts.isNotEmpty) {
        hour = int.parse(timeParts[0]);
        if (timeParts.length > 1) {
          minute = int.parse(timeParts[1]);
        }
      }

      if (hasPm && hour < 12) hour += 12;
      if (hasAm && hour == 12) hour = 0;

      final intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': hour,
          'android.intent.extra.alarm.MINUTES': minute,
          'android.intent.extra.alarm.MESSAGE': message.isEmpty ? 'SEETHA Alarm' : message,
          'android.intent.extra.alarm.SKIP_UI': true,
        },
      );
      
      await intent.launch();
      return true;
    } catch (e) {
      return false;
    }
  }
}
