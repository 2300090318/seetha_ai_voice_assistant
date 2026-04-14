# 🎙️ SEETHA — Personal Voice AI Assistant

A high-performance Android personal assistant built with Flutter, powered by Anthropic's Claude. SEETHA can edit your photos, trim videos, open apps, play music, answer questions with a sweet female voice, set alarms, send WhatsApp messages, search DuckDuckGo, and get the weather.

## Features
- **Voice Operations**: Uses `flutter_tts` & `speech_to_text`. Responds naturally and quickly.
- **Claude Sonnet Engine**: API-driven natural language intelligence context mapping with 13 custom functions.
- **Photo Editor**: Adjust brightness, saturation, apply 10 pre-loaded filters, flip, rotate, crop, text overlays.
- **Video Editor**: FFmpeg integration for speed, audio extracting, muting, merging, trimming, watermarks, compression.
- **Extensive Integrations**: Android intents handle routing to maps, whatsapp, clock, system settings, galleries smoothly.

## Setup
### 1. Requirements
Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed along with [Android Studio](https://developer.android.com/studio) to run Android builds.

### 2. Building Release APK
Clone this project, then run the standard build sequence:

```bash
# Fetch dependencies
flutter pub get

# Build standard architecture release APKs
flutter build apk --release --split-per-abi

# Or build the fat APK (larger size)
flutter build apk --release
```

Look for your generated APKs in `/build/app/outputs/flutter-apk/`.

### 3. Usage
- On launch, the system will prompt you for your Anthropic API Key (`sk-ant-...`). This stays secure using `shared_preferences`.
- Say "Hey Seetha" to wake the system or simply hit the purple microphone overlay.

_Built automatically._
