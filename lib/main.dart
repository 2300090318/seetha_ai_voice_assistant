import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/photo_editor_provider.dart';
import 'providers/video_editor_provider.dart';
import 'utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadAll()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PhotoEditorProvider()),
        ChangeNotifierProvider(create: (_) => VideoEditorProvider()),
      ],
      child: const SeethApp(),
    ),
  );
}
