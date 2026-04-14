import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PhotoFilterStrip extends StatelessWidget {
  final File previewImage;
  final String activeFilter;
  final Function(String) onFilterSelected;

  const PhotoFilterStrip({
    super.key,
    required this.previewImage,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: PhotoFilters.all.length,
        itemBuilder: (context, index) {
          final filterName = PhotoFilters.all[index];
          final isActive = activeFilter == filterName;

          return GestureDetector(
            onTap: () => onFilterSelected(filterName),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isActive ? AppColors.primaryPurple : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      // A real implementation would apply the filter to a thumbnail here.
                      // For performance, we just show the original.
                      image: DecorationImage(
                        image: FileImage(previewImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filterName.toUpperCase(),
                    style: TextStyle(
                      color: isActive ? AppColors.primaryPurple : Colors.white70,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
