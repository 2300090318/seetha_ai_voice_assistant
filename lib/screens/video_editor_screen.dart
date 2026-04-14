import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_editor_provider.dart';
import '../models/video_edit_model.dart';
import '../widgets/edit_toolbar.dart';
import '../widgets/video_timeline.dart';
import '../utils/constants.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initVideo(File file) {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    _videoController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {}); // update UI
      });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VideoEditorProvider>(context);
    final state = provider.state;

    // Handle incoming video changes dynamically
    if (state.currentFile != null && (_videoController == null || _videoController!.dataSource != state.currentFile!.path)) {
       _initVideo(state.currentFile!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Editor'),
        actions: [
          if (provider.hasVideo) ...[
            TextButton(
              onPressed: () async {
                final success = await provider.saveToGallery();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Saved to Gallery' : 'Failed to save'),
                      backgroundColor: success ? AppColors.speaking : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Export', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
      body: !provider.hasVideo
          ? Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.video_library),
                label: const Text('Pick Video'),
                onPressed: () => provider.pickVideo(),
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    // Video Preview
                    Expanded(
                      child: Center(
                        child: _videoController != null && _videoController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    VideoPlayer(_videoController!),
                                    VideoProgressIndicator(_videoController!, allowScrubbing: true),
                                    Center(
                                      child: IconButton(
                                        iconSize: 64,
                                        icon: Icon(
                                          _videoController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const CircularProgressIndicator(),
                      ),
                    ),
                    
                    // Timeline
                    if (state.currentFile != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: VideoTimeline(
                          video: state.currentFile!,
                          start: Duration.zero,
                          end: _videoController?.value.duration ?? const Duration(seconds: 10),
                          onRangeChanged: (s, e) => provider.setTrimRange(s, e),
                        ),
                      ),
                    
                    // Tool Area
                    Container(
                      color: AppColors.cardBg,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (provider.activeTab == 0) _buildTrimTab(provider, state),
                          if (provider.activeTab == 1) _buildSpeedTab(provider, state),
                          if (provider.activeTab == 2) _buildAudioTab(provider, state),
                          if (provider.activeTab == 3) _buildTextTab(provider, state),
                          if (provider.activeTab == 4) _buildFFmpegTab(provider, state),
                          
                          EditToolbar(
                            tabs: const ['Trim', 'Speed', 'Audio', 'Text', 'Ops'],
                            activeIndex: provider.activeTab,
                            onTabSelected: (idx) => provider.setActiveTab(idx),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Progress Dialog Overlays
                if (state.isProcessing)
                  Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Processing video...', style: TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: state.processingProgress,
                              color: AppColors.primaryPurple,
                              backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('${(state.processingProgress * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildTrimTab(VideoEditorProvider provider, VideoEditState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => provider.processTrim(),
        child: const Text('Apply Trim Selection'),
      ),
    );
  }

  Widget _buildSpeedTab(VideoEditorProvider provider, VideoEditState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: VideoSpeeds.all.map((s) {
              final isActive = state.speed == s;
              return InkWell(
                onTap: () => provider.setSpeed(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryPurple : Colors.transparent,
                    border: Border.all(color: AppColors.primaryPurple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${s}x', style: TextStyle(color: isActive ? Colors.white : AppColors.primaryPurple)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.processSpeed(),
            child: const Text('Apply Speed'),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTab(VideoEditorProvider provider, VideoEditState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Mute Original Audio'),
            value: state.isMuted,
            onChanged: (_) {
              provider.toggleMute();
              if (state.isMuted == false) { // Toggled to true
                provider.processMute();
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Mock picking an audio file and applying
              provider.processExtractAudio(); // Extract as demo
            },
            child: const Text('Extract Audio to MP3'),
          )
        ],
      ),
    );
  }

  Widget _buildTextTab(VideoEditorProvider provider, VideoEditState state) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
             Expanded(
              child: TextField(
                onChanged: (text) => provider.setWatermark(text, state.watermarkPosition),
                decoration: const InputDecoration(
                  hintText: 'Watermark Text',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => provider.processWatermark(),
              child: const Text('Add'),
            ),
          ],
        ),
      );
  }

  Widget _buildFFmpegTab(VideoEditorProvider provider, VideoEditState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton(onPressed: () => provider.processCompress('medium'), child: const Text('Compress')),
          ElevatedButton(onPressed: () => provider.processFade(), child: const Text('Add Fade')),
          ElevatedButton(onPressed: () => provider.processExtractAudio(), child: const Text('Extract MP3')),
        ],
      ),
    );
  }
}
