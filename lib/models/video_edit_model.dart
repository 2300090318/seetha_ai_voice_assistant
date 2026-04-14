import 'dart:io';

enum VideoOperation {
  none,
  trim,
  speed,
  mute,
  addMusic,
  compress,
  watermark,
  fadeIn,
  fadeOut,
  merge,
  extractAudio,
}

class VideoEditState {
  final File? originalFile;
  final File? currentFile;
  final Duration? trimStart;
  final Duration? trimEnd;
  final double speed;
  final bool isMuted;
  final File? musicFile;
  final double musicVolume;
  final double originalVolume;
  final String? watermarkText;
  final String watermarkPosition;
  final bool hasFadeIn;
  final bool hasFadeOut;
  final double processingProgress;
  final bool isProcessing;

  const VideoEditState({
    this.originalFile,
    this.currentFile,
    this.trimStart,
    this.trimEnd,
    this.speed = 1.0,
    this.isMuted = false,
    this.musicFile,
    this.musicVolume = 1.0,
    this.originalVolume = 1.0,
    this.watermarkText,
    this.watermarkPosition = 'bottomright',
    this.hasFadeIn = false,
    this.hasFadeOut = false,
    this.processingProgress = 0.0,
    this.isProcessing = false,
  });

  VideoEditState copyWith({
    File? originalFile,
    File? currentFile,
    Duration? trimStart,
    Duration? trimEnd,
    double? speed,
    bool? isMuted,
    File? musicFile,
    double? musicVolume,
    double? originalVolume,
    String? watermarkText,
    String? watermarkPosition,
    bool? hasFadeIn,
    bool? hasFadeOut,
    double? processingProgress,
    bool? isProcessing,
  }) {
    return VideoEditState(
      originalFile: originalFile ?? this.originalFile,
      currentFile: currentFile ?? this.currentFile,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
      speed: speed ?? this.speed,
      isMuted: isMuted ?? this.isMuted,
      musicFile: musicFile ?? this.musicFile,
      musicVolume: musicVolume ?? this.musicVolume,
      originalVolume: originalVolume ?? this.originalVolume,
      watermarkText: watermarkText ?? this.watermarkText,
      watermarkPosition: watermarkPosition ?? this.watermarkPosition,
      hasFadeIn: hasFadeIn ?? this.hasFadeIn,
      hasFadeOut: hasFadeOut ?? this.hasFadeOut,
      processingProgress: processingProgress ?? this.processingProgress,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
