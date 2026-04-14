import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/voice_input_service.dart';
import '../utils/constants.dart';

class MicButton extends StatelessWidget {
  final VoiceState state;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color glowColor = AppColors.idle;
    IconData icon = Icons.mic;
    bool isAnimating = false;

    switch (state) {
      case VoiceState.idle:
        glowColor = AppColors.idle;
        icon = Icons.mic;
        break;
      case VoiceState.listening:
        glowColor = AppColors.listening;
        icon = Icons.mic_none;
        isAnimating = true;
        break;
      case VoiceState.thinking:
        glowColor = AppColors.thinking;
        icon = Icons.more_horiz;
        isAnimating = true;
        break;
      case VoiceState.speaking:
        glowColor = AppColors.speaking;
        icon = Icons.volume_up;
        isAnimating = true;
        break;
    }

    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: glowColor.withOpacity(0.2),
          border: Border.all(color: glowColor.withOpacity(0.5), width: 2),
        ),
        child: Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: glowColor,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    if (isAnimating) {
      if (state == VoiceState.listening) {
        button = button.animate(onPlay: (controller) => controller.repeat())
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut)
            .then()
            .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 1000.ms, curve: Curves.easeInOut);
      } else if (state == VoiceState.thinking) {
        button = button.animate(onPlay: (controller) => controller.repeat())
           .shimmer(duration: 1500.ms, color: Colors.white, angle: 1);
      } else if (state == VoiceState.speaking) {
         button = button.animate(onPlay: (controller) => controller.repeat())
            .shakeY(amount: 3, duration: 2000.ms);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 20),
        Text(
          _getStatusLabel(),
          style: TextStyle(
            color: glowColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  String _getStatusLabel() {
    switch (state) {
      case VoiceState.idle:
        return StatusLabels.idle;
      case VoiceState.listening:
        return StatusLabels.listening;
      case VoiceState.thinking:
        return StatusLabels.thinking;
      case VoiceState.speaking:
        return StatusLabels.speaking;
    }
  }
}
