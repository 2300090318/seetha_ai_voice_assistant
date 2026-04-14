import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/settings_provider.dart';
import '../providers/chat_provider.dart';
import '../services/claude_service.dart';
import '../services/voice_input_service.dart';
import '../services/voice_output_service.dart';
import '../services/app_launcher_service.dart';
import '../services/music_service.dart';
import '../services/weather_service.dart';
import '../services/contacts_service.dart';
import '../services/alarm_service.dart';
import '../services/web_search_service.dart';
import '../services/news_service.dart';
import '../models/tool_result_model.dart';
import '../utils/constants.dart';

import '../widgets/mic_button.dart';
import '../widgets/transcript_card.dart';
import '../widgets/response_card.dart';
import '../widgets/quick_action_bar.dart';

import 'settings_screen.dart';
import 'chat_history_screen.dart';
import 'photo_editor_screen.dart';
import 'video_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ClaudeService _claudeService;
  late VoiceInputService _voiceInput;
  late VoiceOutputService _voiceOutput;

  // Tools
  final _appLauncher = AppLauncherService();
  final _musicService = MusicService();
  final _weatherService = WeatherService();
  final _contactsService = SeethaContactsService();
  final _alarmService = AlarmService();
  final _webSearch = WebSearchService();
  final _newsService = NewsService();

  String _currentTranscript = '';
  String _currentResponse = '';
  bool _isResponseAnimating = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    _claudeService = ClaudeService(apiKey: settings.apiKey);

    _voiceOutput = VoiceOutputService();
    await _voiceOutput.initialize(
      speechRate: settings.voiceSpeed,
      pitch: settings.voicePitch,
      language: settings.language,
    );

    _voiceOutput.onSpeakingStart = () {
      if (mounted) _voiceInput.setSpeaking();
    };
    _voiceOutput.onSpeakingComplete = () {
      if (mounted) _voiceInput.setIdle();
    };

    _voiceInput = VoiceInputService();
    final avail = await _voiceInput.initialize();
    if (avail && settings.wakeWordEnabled) {
      // In a real app, you'd use a lightweight offline wake word engine like Porcupine.
      // Here we just attach standard speech recognition if enabled for demo.
    }

    _voiceInput.onTranscriptUpdate = (text) {
      if (mounted) setState(() => _currentTranscript = text);
    };

    _voiceInput.onStateChange = (state) {
      if (mounted) setState(() {});
    };

    _voiceInput.onFinalResult = (text) async {
      await _processUserMessage(text);
    };
  }

  @override
  void dispose() {
    _voiceInput.dispose();
    _voiceOutput.dispose();
    super.dispose();
  }

  void _onMicTap() async {
    if (_voiceInput.state == VoiceState.listening) {
      await _voiceInput.stopListening();
    } else if (_voiceInput.state == VoiceState.speaking || _voiceOutput.isSpeaking) {
      await _voiceOutput.stop();
      _voiceInput.setIdle();
    } else {
      setState(() {
        _currentTranscript = '';
        _currentResponse = '';
      });
      await _voiceInput.startListening();
    }
  }

  void _onQuickAction(String command) {
    setState(() {
      _currentTranscript = command;
      _currentResponse = '';
    });
    _voiceInput.setThinking();
    _processUserMessage(command);
  }

  Future<void> _processUserMessage(String text) async {
    if (text.isEmpty) {
      _voiceInput.setIdle();
      return;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.hasApiKey) {
      _showResponse(AppStrings.noApiKey);
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
      return;
    }

    _voiceInput.setThinking();
    setState(() => _currentResponse = '');

    final result = await _claudeService.sendMessage(text);
    await _handleClaudeResult(result, text);
  }

  Future<void> _handleClaudeResult(Map<String, dynamic> result, String originalText) async {
    if (result['type'] == 'error') {
      _showResponse(result['text'], toolName: result['code']?.toString());
      return;
    }

    if (result['type'] == 'text') {
      _showResponse(result['text'], originalText: originalText);
      return;
    }

    if (result['type'] == 'tool_use') {
      final toolName = result['tool_name'] as String;
      final toolInput = result['tool_input'] as Map<String, dynamic>;
      final toolUseId = result['tool_use_id'] as String;
      final rawContent = result['raw_content'] as List<dynamic>;

      String toolOutputStr = '';
      bool isError = false;

      try {
        toolOutputStr = await _executeTool(toolName, toolInput);
      } catch (e) {
        toolOutputStr = 'Tool execution failed: $e';
        isError = true;
      }

      // If the tool is opening a screen, we don't necessarily need to ping Claude back right away, 
      // but standard Tool_Use flow expects a tool_result back.
      final toolResult = ToolResultModel(
        toolUseId: toolUseId,
        content: toolOutputStr,
        isError: isError,
      );

      final finalText = await _claudeService.sendToolResult(
        toolResult, 
        rawContent.cast<Map<String,dynamic>>()
      );
      
      _showResponse(finalText, originalText: originalText, toolName: toolName);
    }
  }

  Future<String> _executeTool(String toolName, Map<String, dynamic> input) async {
    switch (toolName) {
      case 'open_app':
        final res = await _appLauncher.openApp(input['app_name']);
        return res ? 'App opened successfully' : 'App not found';

      case 'play_music':
        final res = await _musicService.play(input['song_name'], input['platform'] ?? 'auto');
        return res ? 'Music started' : 'Failed to play music';

      case 'search_web':
        final res = await _webSearch.searchDuckDuckGo(input['query']);
        return res ? 'Web browser opened with search' : 'Failed to search';

      case 'get_weather':
        return await _weatherService.getWeather(input['city']);

      case 'get_news':
        return await _newsService.getNews(input['topic'] ?? '');

      case 'get_current_time':
        final now = DateTime.now();
        return 'Current time is ${now.hour}:${now.minute.toString().padLeft(2, '0')}, Date: ${now.toIso8601String().split('T')[0]}';

      case 'make_call':
        final res = await _contactsService.makeCall(input['contact_name']);
        return res ? 'Call initiated' : 'Contact not found or call failed';

      case 'send_whatsapp':
        final res = await _contactsService.sendWhatsApp(input['contact_name'], input['message']);
        return res ? 'WhatsApp opened' : 'Contact not found or failed';

      case 'set_alarm':
        final res = await _alarmService.setAlarm(input['time'], input['label'] ?? '');
        return res ? 'Alarm set' : 'Failed to set alarm';

      case 'pick_photo_from_gallery':
      case 'edit_photo':
        if (mounted) {
           Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PhotoEditorScreen()));
        }
        return 'Opened photo editor';

      case 'pick_video_from_gallery':
      case 'edit_video':
         if (mounted) {
           Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VideoEditorScreen()));
        }
        return 'Opened video editor';

      default:
        return 'Tool $toolName not implemented on device yet';
    }
  }

  void _showResponse(String text, {String? originalText, String? toolName}) async {
    if (!mounted) return;
    
    setState(() {
      _currentResponse = text;
      _isResponseAnimating = true;
    });

    if (originalText != null) {
      final chat = Provider.of<ChatProvider>(context, listen: false);
      chat.addMessage(
        userMsg: originalText,
        seethaMsg: text,
        toolUsed: toolName,
      );
    }

    await _voiceOutput.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEETHA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  MicButton(
                    state: _voiceInput.state,
                    onTap: _onMicTap,
                  ),
                  const SizedBox(height: 40),
                  TranscriptCard(text: _currentTranscript),
                  ResponseCard(
                    text: _currentResponse, 
                    animate: _isResponseAnimating,
                  ),
                ],
              ),
            ),
          ),
          QuickActionBar(onActionSelected: _onQuickAction),
          const SizedBox(height: 10),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', true, () {}),
          _buildNavItem(Icons.history, 'History', false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatHistoryScreen()));
          }),
          _buildNavItem(Icons.settings, 'Settings', false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    final color = isActive ? AppColors.primaryPurple : Colors.white54;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
