import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QuickActionBar extends StatelessWidget {
  final Function(String) onActionSelected;

  const QuickActionBar({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.music_note, 'label': 'Music', 'cmd': 'play music'},
      {'icon': Icons.photo_filter, 'label': 'Photo Edit', 'cmd': 'open photo editor'},
      {'icon': Icons.movie_edit, 'label': 'Video Edit', 'cmd': 'open video editor'},
      {'icon': Icons.search, 'label': 'Search', 'cmd': 'search the web'},
      {'icon': Icons.chat, 'label': 'Chat', 'cmd': 'open whatsapp'},
      {'icon': Icons.call, 'label': 'Call', 'cmd': 'make a call'},
      {'icon': Icons.alarm, 'label': 'Alarm', 'cmd': 'set an alarm'},
      {'icon': Icons.wb_sunny, 'label': 'Weather', 'cmd': 'what is the weather'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildActionItem(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: () => onActionSelected(action['cmd'] as String),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryPurple.withOpacity(0.5)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
