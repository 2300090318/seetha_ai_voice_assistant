import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/photo_editor_provider.dart';
import '../models/photo_edit_model.dart';
import '../widgets/edit_toolbar.dart';
import '../widgets/photo_filter_strip.dart';
import '../utils/constants.dart';

class PhotoEditorScreen extends StatefulWidget {
  const PhotoEditorScreen({super.key});

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PhotoEditorProvider>(context);
    final state = provider.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Editor'),
        actions: [
          if (provider.hasPhoto) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: state.undoStack.isNotEmpty ? () => provider.undo() : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => provider.reset(),
            ),
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
              child: const Text('Save', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
      body: !provider.hasPhoto
          ? Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick Photo'),
                onPressed: () => provider.pickPhoto(),
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    // Preview Area
                    Expanded(
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: state.currentFile != null
                              ? Image.file(state.currentFile!)
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    
                    // Tool Area
                    Container(
                      color: AppColors.cardBg,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (provider.activeTab == 0) _buildAdjustTab(provider, state),
                          if (provider.activeTab == 1) _buildFiltersTab(provider, state),
                          if (provider.activeTab == 2) _buildCropTab(provider),
                          if (provider.activeTab == 3) _buildTextTab(provider),
                          
                          EditToolbar(
                            tabs: const ['Adjust', 'Filters', 'Crop', 'Text'],
                            activeIndex: provider.activeTab,
                            onTabSelected: (idx) => provider.setActiveTab(idx),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (provider.isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryPurple),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildAdjustTab(PhotoEditorProvider provider, PhotoEditState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSliderOption('Brightness', state.brightness, -100, 100, (v) => provider.adjustBrightness(v)),
          _buildSliderOption('Contrast', state.contrast, -100, 100, (v) => provider.adjustContrast(v)),
          _buildSliderOption('Saturation', state.saturation, -100, 100, (v) => provider.adjustSaturation(v)),
        ],
      ),
    );
  }

  Widget _buildSliderOption(String label, double value, double min, double max, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChangeEnd: onChanged,
            onChanged: (v) {}, // Need local state for smooth drag in real app
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersTab(PhotoEditorProvider provider, PhotoEditState state) {
    if (state.originalFile == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PhotoFilterStrip(
        previewImage: state.originalFile!,
        activeFilter: state.activeFilter ?? 'original',
        onFilterSelected: (f) => provider.applyFilter(f),
      ),
    );
  }

  Widget _buildCropTab(PhotoEditorProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.crop_free, 'Free', () => provider.cropPhoto('free')),
          _buildActionButton(Icons.crop_square, '1:1', () => provider.cropPhoto('1:1')),
          _buildActionButton(Icons.crop_16_9, '16:9', () => provider.cropPhoto('16:9')),
          _buildActionButton(Icons.rotate_right, 'Rot R', () => provider.rotatePhoto(90)),
          _buildActionButton(Icons.flip, 'Flip H', () => provider.flipPhoto('horizontal')),
        ],
      ),
    );
  }

  Widget _buildTextTab(PhotoEditorProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter text...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                provider.addTextOverlay(TextOverlayItem(
                  text: _textController.text,
                  x: 50,
                  y: 50,
                  fontSize: 48,
                  color: '#FFFFFF',
                ));
                _textController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
