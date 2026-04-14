import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TranscriptCard extends StatelessWidget {
  final String text;

  const TranscriptCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You said',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
