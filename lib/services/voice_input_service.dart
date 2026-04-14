import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

enum VoiceState { idle, listening, thinking, speaking }

class VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  String _transcript = '';
  VoiceState _state = VoiceState.idle;

  VoiceState get state => _state;
  String get transcript => _transcript;
  bool get isAvailable => _isAvailable;

  // Callbacks
  void Function(String)? onTranscriptUpdate;
  void Function(String)? onFinalResult;
  void Function(double)? onSoundLevel;
  void Function(VoiceState)? onStateChange;

  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
      onStatus: _onStatus,
      onError: (error) {
        // ignore: avoid_print
        print('Speech error: $error');
      },
    );
    return _isAvailable;
  }

  Future<void> startListening({String locale = 'en-US'}) async {
    if (!_isAvailable) return;
    _transcript = '';
    _setState(VoiceState.listening);

    await _speech.listen(
      onResult: _onResult,
      localeId: locale,
      listenMode: ListenMode.dictation,
      pauseFor: const Duration(seconds: 6),
      onSoundLevelChange: (level) => onSoundLevel?.call(level),
      listenFor: const Duration(seconds: 60),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _setState(VoiceState.thinking);
  }

  void cancelListening() {
    _speech.cancel();
    _setState(VoiceState.idle);
  }

  void setThinking() => _setState(VoiceState.thinking);
  void setSpeaking() => _setState(VoiceState.speaking);
  void setIdle() => _setState(VoiceState.idle);

  void _onResult(SpeechRecognitionResult result) {
    _transcript = result.recognizedWords;
    onTranscriptUpdate?.call(_transcript);

    if (result.finalResult) {
      onFinalResult?.call(_transcript);
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (_state == VoiceState.listening && _transcript.isNotEmpty) {
        onFinalResult?.call(_transcript);
      }
    }
  }

  void _setState(VoiceState state) {
    _state = state;
    onStateChange?.call(state);
  }

  bool containsWakeWord(String text) {
    final lower = text.toLowerCase();
    return lower.contains('hey seetha') || lower.startsWith('seetha');
  }

  void dispose() {
    _speech.cancel();
  }
}
