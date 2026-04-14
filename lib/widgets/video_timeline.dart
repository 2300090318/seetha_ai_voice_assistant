import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';

class VideoTimeline extends StatefulWidget {
  final File video;
  final Duration start;
  final Duration end;
  final Function(Duration, Duration) onRangeChanged;

  const VideoTimeline({
    super.key,
    required this.video,
    required this.start,
    required this.end,
    required this.onRangeChanged,
  });

  @override
  State<VideoTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends State<VideoTimeline> {
  List<String> _thumbnails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnails();
  }

  Future<void> _generateThumbnails() async {
    // In a real app, generate multiple thumbnails across the video duration.
    // Here we generate one as a placeholder for the strip.
    try {
        final tempDir = await getTemporaryDirectory();
        final path = await VideoThumbnail.thumbnailFile(
          video: widget.video.path,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 100,
          quality: 25,
        );
        if (path != null && mounted) {
          setState(() {
            _thumbnails = List.generate(8, (_) => path); // Mock strip 
            _isLoading = false;
          });
        }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
      );
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryPurple),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _thumbnails.length,
            itemBuilder: (context, index) {
              return Image.file(
                File(_thumbnails[index]),
                height: 60,
                width: MediaQuery.of(context).size.width / 10,
                fit: BoxFit.cover,
              );
            },
          ),
          // Mock trim handles - in a full implementation this would be interactive sliders
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
              color: AppColors.primaryPurple,
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }
}
