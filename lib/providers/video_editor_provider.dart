import 'dart:io';
import 'package:flutter/material.dart';
import '../models/video_edit_model.dart';
import '../services/video_edit_service.dart';

class VideoEditorProvider extends ChangeNotifier {
  VideoEditState _state = const VideoEditState();
  final VideoEditService _service = VideoEditService();
  int _activeTab = 0; // 0=Trim, 1=Speed, 2=Audio, 3=Text, 4=Watermark

  VideoEditState get state => _state;
  int get activeTab => _activeTab;
  bool get hasVideo => _state.currentFile != null;

  void setActiveTab(int tab) {
    _activeTab = tab;
    notifyListeners();
  }

  Future<void> pickVideo() async {
    final file = await _service.pickVideo();
    if (file != null) {
      _state = VideoEditState(
        originalFile: file,
        currentFile: file,
      );
      notifyListeners();
    }
  }

  Future<void> loadVideo(File file) async {
    _state = VideoEditState(
      originalFile: file,
      currentFile: file,
    );
    notifyListeners();
  }

  void setTrimRange(Duration start, Duration end) {
    _state = _state.copyWith(trimStart: start, trimEnd: end);
    notifyListeners();
  }

  void setSpeed(double speed) {
    _state = _state.copyWith(speed: speed);
    notifyListeners();
  }

  void toggleMute() {
    _state = _state.copyWith(isMuted: !_state.isMuted);
    notifyListeners();
  }

  void setMusicFile(File? file) {
    _state = _state.copyWith(musicFile: file);
    notifyListeners();
  }

  void setMusicVolume(double vol) {
    _state = _state.copyWith(musicVolume: vol);
    notifyListeners();
  }

  void setOriginalVolume(double vol) {
    _state = _state.copyWith(originalVolume: vol);
    notifyListeners();
  }

  void setWatermark(String text, String position) {
    _state = _state.copyWith(
        watermarkText: text, watermarkPosition: position);
    notifyListeners();
  }

  void toggleFadeIn() {
    _state = _state.copyWith(hasFadeIn: !_state.hasFadeIn);
    notifyListeners();
  }

  void toggleFadeOut() {
    _state = _state.copyWith(hasFadeOut: !_state.hasFadeOut);
    notifyListeners();
  }

  Future<File?> processTrim() async {
    if (_state.currentFile == null) return null;
    _setProgress(0.0, true);
    final result = await _service.trimVideo(
      _state.currentFile!,
      _state.trimStart ?? Duration.zero,
      _state.trimEnd ?? const Duration(hours: 1),
      onProgress: (p) => _setProgress(p, true),
    );
    if (result != null) {
      _state = _state.copyWith(currentFile: result);
    }
    _setProgress(1.0, false);
    return result;
  }

  Future<File?> processSpeed() async {
    if (_state.currentFile == null) return null;
    _setProgress(0.0, true);
    final result = await _service.changeSpeed(
      _state.currentFile!,
      _state.speed,
      onProgress: (p) => _setProgress(p, true),
    );
    if (result != null) {
      _state = _state.copyWith(currentFile: result);
    }
    _setProgress(1.0, false);
    return result;
  }

  Future<File?> processMute() async {
    if (_state.currentFile == null) return null;
    _setProgress(0.0, true);
    final result = await _service.muteVideo(
      _state.currentFile!,
      onProgress: (p) => _setProgress(p, true),
    );
    if (result != null) {
      _state = _state.copyWith(currentFile: result, isMuted: true);
    }
    _setProgress(1.0, false);
    return result;
  }

  Future<File?> processAddMusic() async {
    if (_state.currentFile == null || _state.musicFile == null) return null;
    _setProgress(0.0, true);
    final result = await _service.addMusic(
      _state.currentFile!,
      _state.musicFile!,
      onProgress: (p) => _setProgress(p, true),
    );
    if (result != null) {
      _state = _state.copyWith(currentFile: result);
    }
    _setProgress(1.0, false);
    return result;
  }

  Future<File?> processCompress(String quality) async {
    if (_state.currentFile == null) return null;
    _setProgress(0.0, true);
    final result = await _service.compressVideo(
      _state.currentFile!,
      quality,
      onProgress: (p) => _setProgress(p, true),
    );
    if (result != null) {
      _state = _state.copyWith(currentFile: result);
    }
    _setProgress(1.0, false);
    return result;
  }

  Future<File?> processWatermark() async {
    if (_state.currentFile == null || _state.watermarkText == null) return null;
    _setProgress(0.0, true);
    final result = await _service.addWatermark(
      _state.currentFile!,
      _state.watermarkText!,
      _state.watermarkPosition,
      onProgress: (p) => _setProgress(p, true),
    );
    if (result != null) {
      _state = _state.copyWith(currentFile: result);
    }
    _setProgress(1.0, false);
    return result;
  }

  Future<File?> processFade() async {
    if (_state.currentFile == null) return null;
    _setProgress(0.0, true);
    final result = await _service.addFade(
      _state.currentFile!,
      _state.hasFadeIn,
      _state.hasFadeOut,
      onProgress: (p) => _setProgress(p, true),
    );
    if (result != null) {
      _state = _state.copyWith(currentFile: result);
    }
    _setProgress(1.0, false);
    return result;
  }

  Future<File?> processMerge(List<File> videos) async {
    _setProgress(0.0, true);
    final result = await _service.mergeVideos(
      videos,
      onProgress: (p) => _setProgress(p, true),
    );
    if (result != null) {
      _state = _state.copyWith(currentFile: result);
    }
    _setProgress(1.0, false);
    return result;
  }

  Future<File?> processExtractAudio() async {
    if (_state.currentFile == null) return null;
    _setProgress(0.0, true);
    final result = await _service.extractAudio(
      _state.currentFile!,
      onProgress: (p) => _setProgress(p, true),
    );
    _setProgress(1.0, false);
    return result;
  }

  Future<bool> saveToGallery() async {
    if (_state.currentFile == null) return false;
    return await _service.saveToGallery(_state.currentFile!);
  }

  void _setProgress(double progress, bool isProcessing) {
    _state = _state.copyWith(
      processingProgress: progress,
      isProcessing: isProcessing,
    );
    notifyListeners();
  }
}
