import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EditToolbar extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final Function(int) onTabSelected;

  const EditToolbar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (index) {
          final isActive = index == activeIndex;
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
