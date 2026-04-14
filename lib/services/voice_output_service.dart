import 'package:flutter_tts/flutter_tts.dart';

class VoiceOutputService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  void Function()? onSpeakingStart;
  void Function()? onSpeakingComplete;

  Future<void> initialize({
    double speechRate = 0.48,
    double pitch = 1.1,
    String language = 'en-US',
  }) async {
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(speechRate);
    await _tts.setPitch(pitch);
    await _tts.setVolume(1.0);

    // Try to pick a female voice for sweet girl voice
    final voices = await _tts.getVoices;
    if (voices != null) {
      final femaleVoice = (voices as List).firstWhere(
        (v) {
          final name = (v['name'] ?? '').toString().toLowerCase();
          return name.contains('female') ||
              name.contains('samantha') ||
              name.contains('victoria') ||
              name.contains('karen') ||
              name.contains('zira') ||
              name.contains('salli') ||
              name.contains('joanna');
        },
        orElse: () => null,
      );
      if (femaleVoice != null) {
        await _tts.setVoice({
          'name': femaleVoice['name'],
          'locale': femaleVoice['locale'] ?? language,
        });
      }
    }

    _tts.setStartHandler(() {
      _isSpeaking = true;
      onSpeakingStart?.call();
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      onSpeakingComplete?.call();
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      onSpeakingComplete?.call();
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    // Strip any markdown or special characters
    final cleaned = text
        .replaceAll(RegExp(r'[*_`#>]'), '')
        .replaceAll(RegExp(r'\n+'), '. ')
        .trim();
    await _tts.stop();
    await _tts.speak(cleaned);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> updateSettings({double? rate, double? pitch}) async {
    if (rate != null) await _tts.setSpeechRate(rate);
    if (pitch != null) await _tts.setPitch(pitch);
  }

  void dispose() {
    _tts.stop();
  }
}
