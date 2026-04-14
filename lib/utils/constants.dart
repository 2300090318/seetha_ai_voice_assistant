// ─── App Colors ───────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0a0a0a);
  static const Color primaryPurple = Color(0xFF7c3aed);
  static const Color secondaryBlue = Color(0xFF3b82f6);
  static const Color cardBg = Color(0xFF1a1a2e);
  static const Color textWhite = Color(0xFFFFFFFF);

  // State Colors
  static const Color idle = Color(0xFF7c3aed);
  static const Color listening = Color(0xFF3b82f6);
  static const Color thinking = Color(0xFFf59e0b);
  static const Color speaking = Color(0xFF10b981);
}

// ─── App Strings ──────────────────────────────────────────────────────────────
class AppStrings {
  static const String appName = 'SEETHA';
  static const String tagline = 'Your Voice. Your Assistant.';
  static const String model = 'claude-sonnet-4-20250514';
  static const String baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String anthropicVersion = '2023-06-01';
  static const String apiKeyPrefKey = 'anthropic_api_key';
  static const String voiceSpeedKey = 'voice_speed';
  static const String voicePitchKey = 'voice_pitch';
  static const String isDarkThemeKey = 'is_dark_theme';
  static const String wakeWordKey = 'wake_word_enabled';
  static const String languageKey = 'language';

  static const String systemPrompt = '''
You are Seetha, a professional personal voice assistant on Android.
You help users edit photos, edit videos, open apps, play music,
search the web, make calls, send messages, set alarms, and answer
any question. Always respond in short clear spoken sentences.
Never use markdown, bullet points, emojis, or special characters.
Be friendly, warm, and concise. You have a sweet and pleasant personality.
When user wants to edit a photo or video, always call the appropriate tool immediately.
When asked about the time, date, or weather, always use your tools.
''';

  // Error messages
  static const String noInternet = 'I am having trouble connecting.';
  static const String appNotFound = 'I could not find that app.';
  static const String noApiKey = 'Please add your Anthropic API key in settings.';
  static const String invalidApiKey = 'Your API key seems incorrect. Please check settings.';
  static const String expiredApiKey = 'Your API key is not working. Please update it in settings.';
  static const String noPhotoSelected = 'No photo was selected.';
  static const String noVideoSelected = 'No video was selected.';
  static const String ffmpegFail = 'Video processing failed. Please try again.';
  static const String micDenied = 'Please allow microphone access in settings.';
  static const String storageDenied = 'Please allow storage access in settings.';
  static const String contactNotFound = 'I could not find that contact.';
  static const String claudeError = 'Something went wrong. Please try again.';
  static const String speechUnclear = 'Sorry, I did not catch that. Please try again.';
}

// ─── Status labels ────────────────────────────────────────────────────────────
class StatusLabels {
  static const String idle = 'Tap to speak';
  static const String listening = 'Listening...';
  static const String thinking = 'Thinking...';
  static const String speaking = 'Speaking...';
}

// ─── Photo Filters ────────────────────────────────────────────────────────────
class PhotoFilters {
  static const List<String> all = [
    'original', 'vivid', 'cool', 'warm', 'fade',
    'bw', 'sepia', 'drama', 'chrome', 'noir',
  ];
}

// ─── Video Speeds ─────────────────────────────────────────────────────────────
class VideoSpeeds {
  static const List<double> all = [0.25, 0.5, 1.0, 1.5, 2.0, 3.0];
}

// ─── Known App Packages ───────────────────────────────────────────────────────
class KnownApps {
  static const Map<String, String> packages = {
    'whatsapp': 'com.whatsapp',
    'youtube': 'com.google.android.youtube',
    'chrome': 'com.android.chrome',
    'instagram': 'com.instagram.android',
    'spotify': 'com.spotify.music',
    'snapchat': 'com.snapchat.android',
    'facebook': 'com.facebook.katana',
    'twitter': 'com.twitter.android',
    'tiktok': 'com.zhiliaoapp.musically',
    'telegram': 'org.telegram.messenger',
    'capcut': 'com.lemon.lvoverseas',
    'snapseed': 'com.niksoftware.snapseed',
    'lightroom': 'com.adobe.lrmobile',
    'netflix': 'com.netflix.mediaclient',
    'gmail': 'com.google.android.gm',
    'maps': 'com.google.android.maps',
    'camera': 'android.media.action.IMAGE_CAPTURE',
    'gallery': 'com.google.android.apps.photos',
    'settings': 'android.settings.SETTINGS',
    'calculator': 'com.google.android.calculator',
    'calendar': 'com.google.android.calendar',
    'clock': 'com.google.android.deskclock',
    'contacts': 'com.google.android.contacts',
    'files': 'com.google.android.documentsui',
  };
}
