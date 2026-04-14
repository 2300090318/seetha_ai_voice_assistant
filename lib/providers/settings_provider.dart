import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  String _apiKey = '';
  double _voiceSpeed = 0.5;
  double _voicePitch = 1.0;
  bool _isDarkTheme = true;
  bool _wakeWordEnabled = true;
  String _language = 'en-US';

  // ─── Getters ────────────────────────────────────────────────────────────────
  String get apiKey => _apiKey;
  double get voiceSpeed => _voiceSpeed;
  double get voicePitch => _voicePitch;
  bool get isDarkTheme => _isDarkTheme;
  bool get wakeWordEnabled => _wakeWordEnabled;
  String get language => _language;

  bool get hasApiKey =>
      _apiKey.isNotEmpty &&
      _apiKey.startsWith('sk-ant-') &&
      _apiKey.length >= 40;

  // ─── Load All ───────────────────────────────────────────────────────────────
  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(AppStrings.apiKeyPrefKey) ?? '';
    _voiceSpeed = prefs.getDouble(AppStrings.voiceSpeedKey) ?? 0.5;
    _voicePitch = prefs.getDouble(AppStrings.voicePitchKey) ?? 1.0;
    _isDarkTheme = prefs.getBool(AppStrings.isDarkThemeKey) ?? true;
    _wakeWordEnabled = prefs.getBool(AppStrings.wakeWordKey) ?? true;
    _language = prefs.getString(AppStrings.languageKey) ?? 'en-US';
    notifyListeners();
  }

  // ─── Save API Key ────────────────────────────────────────────────────────────
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.apiKeyPrefKey, key);
    _apiKey = key;
    notifyListeners();
  }

  // ─── Save Voice Speed ────────────────────────────────────────────────────────
  Future<void> saveVoiceSpeed(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppStrings.voiceSpeedKey, value);
    _voiceSpeed = value;
    notifyListeners();
  }

  // ─── Save Voice Pitch ─────────────────────────────────────────────────────
  Future<void> saveVoicePitch(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppStrings.voicePitchKey, value);
    _voicePitch = value;
    notifyListeners();
  }

  // ─── Toggle Dark Theme ───────────────────────────────────────────────────────
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = !_isDarkTheme;
    await prefs.setBool(AppStrings.isDarkThemeKey, _isDarkTheme);
    notifyListeners();
  }

  // ─── Toggle Wake Word ────────────────────────────────────────────────────────
  Future<void> toggleWakeWord() async {
    final prefs = await SharedPreferences.getInstance();
    _wakeWordEnabled = !_wakeWordEnabled;
    await prefs.setBool(AppStrings.wakeWordKey, _wakeWordEnabled);
    notifyListeners();
  }

  // ─── Save Language ───────────────────────────────────────────────────────────
  Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.languageKey, lang);
    _language = lang;
    notifyListeners();
  }
}
