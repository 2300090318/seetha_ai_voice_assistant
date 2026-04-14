import 'dart:io';

enum PhotoOperation {
  none,
  brightness,
  contrast,
  saturation,
  sharpness,
  warmth,
  filter,
  crop,
  rotate,
  flip,
  textOverlay,
}

class PhotoEditState {
  final File? originalFile;
  final File? currentFile;
  final double brightness;
  final double contrast;
  final double saturation;
  final double sharpness;
  final double warmth;
  final String? activeFilter;
  final List<TextOverlayItem> textOverlays;
  final List<File> undoStack;

  const PhotoEditState({
    this.originalFile,
    this.currentFile,
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.sharpness = 0,
    this.warmth = 0,
    this.activeFilter,
    this.textOverlays = const [],
    this.undoStack = const [],
  });

  PhotoEditState copyWith({
    File? originalFile,
    File? currentFile,
    double? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
    double? warmth,
    String? activeFilter,
    List<TextOverlayItem>? textOverlays,
    List<File>? undoStack,
  }) {
    return PhotoEditState(
      originalFile: originalFile ?? this.originalFile,
      currentFile: currentFile ?? this.currentFile,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      sharpness: sharpness ?? this.sharpness,
      warmth: warmth ?? this.warmth,
      activeFilter: activeFilter ?? this.activeFilter,
      textOverlays: textOverlays ?? this.textOverlays,
      undoStack: undoStack ?? this.undoStack,
    );
  }
}

class TextOverlayItem {
  final String text;
  final double x;
  final double y;
  final double fontSize;
  final String color;
  final String id;

  TextOverlayItem({
    required this.text,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.color,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();
}
