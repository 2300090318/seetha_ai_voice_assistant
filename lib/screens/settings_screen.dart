import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool isFirstLaunch;
  const SettingsScreen({super.key, this.isFirstLaunch = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _apiKeyController = TextEditingController(text: settings.apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final key = _apiKeyController.text.trim();
    if (!key.startsWith('sk-ant-') || key.length < 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.invalidApiKey), backgroundColor: Colors.red),
      );
      return;
    }
    
    await Provider.of<SettingsProvider>(context, listen: false).saveApiKey(key);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key saved successfully'), backgroundColor: AppColors.speaking),
      );
      if (widget.isFirstLaunch) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final chat = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: widget.isFirstLaunch ? null : const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('AI Settings'),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            decoration: InputDecoration(
              labelText: 'Anthropic API Key',
              hintText: 'sk-ant-...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                onTap: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveKey,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Save API Key'),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Voice Settings'),
          ListTile(
            title: const Text('Voice Speed'),
            subtitle: Slider(
              value: settings.voiceSpeed,
              min: 0.1,
              max: 1.0,
              onChanged: (v) => settings.saveVoiceSpeed(v),
            ),
          ),
          ListTile(
            title: const Text('Voice Pitch'),
            subtitle: Slider(
              value: settings.voicePitch,
              min: 0.5,
              max: 2.0,
              onChanged: (v) => settings.saveVoicePitch(v),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Assistant Settings'),
          SwitchListTile(
            title: const Text('Wake Word (Hey Seetha)'),
            value: settings.wakeWordEnabled,
            onChanged: (v) => settings.toggleWakeWord(),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: settings.isDarkTheme,
            onChanged: (v) => settings.toggleTheme(),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Storage'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Chat History'),
            onTap: () async {
              await chat.clearAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              }
            },
          ),

          const SizedBox(height: 32),
          const Center(
            child: Text(
              'App Version: 1.0.0\nPowered by Claude AI',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
