import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../utils/constants.dart';

class ResponseCard extends StatelessWidget {
  final String text;
  final bool animate;

  const ResponseCard({
    super.key,
    required this.text,
    this.animate = false,
  });

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
        border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.secondaryBlue, size: 16),
              const SizedBox(width: 8),
              Text(
                'Seetha',
                style: TextStyle(
                  color: AppColors.secondaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: animate
                  ? AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          text,
                          textStyle: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            height: 1.4,
                          ),
                          speed: const Duration(milliseconds: 30),
                        ),
                      ],
                      isRepeatingAnimation: false,
                      displayFullTextOnTap: true,
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
