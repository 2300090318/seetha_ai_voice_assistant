import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_edit_model.dart';
import '../services/photo_edit_service.dart';

class PhotoEditorProvider extends ChangeNotifier {
  PhotoEditState _state = const PhotoEditState();
  final PhotoEditService _service = PhotoEditService();
  bool _isProcessing = false;
  int _activeTab = 0; // 0=Adjust, 1=Filters, 2=Crop, 3=Text

  PhotoEditState get state => _state;
  bool get isProcessing => _isProcessing;
  int get activeTab => _activeTab;
  bool get hasPhoto => _state.currentFile != null;

  void setActiveTab(int tab) {
    _activeTab = tab;
    notifyListeners();
  }

  Future<void> pickPhoto() async {
    final file = await _service.pickPhoto();
    if (file != null) {
      _state = PhotoEditState(
        originalFile: file,
        currentFile: file,
      );
      notifyListeners();
    }
  }

  Future<void> loadPhoto(File file) async {
    _state = PhotoEditState(
      originalFile: file,
      currentFile: file,
    );
    notifyListeners();
  }

  Future<void> adjustBrightness(double value) async {
    if (_state.currentFile == null) return;
    _setProcessing(true);
    final result =
        await _service.adjustBrightness(_state.currentFile!, value);
    _state = _state.copyWith(
      currentFile: result,
      brightness: value,
      undoStack: [..._state.undoStack, _state.currentFile!],
    );
    _setProcessing(false);
  }

  Future<void> adjustContrast(double value) async {
    if (_state.currentFile == null) return;
    _setProcessing(true);
    final result =
        await _service.adjustContrast(_state.currentFile!, value);
    _state = _state.copyWith(
      currentFile: result,
      contrast: value,
      undoStack: [..._state.undoStack, _state.currentFile!],
    );
    _setProcessing(false);
  }

  Future<void> adjustSaturation(double value) async {
    if (_state.currentFile == null) return;
    _setProcessing(true);
    final result =
        await _service.adjustSaturation(_state.currentFile!, value);
    _state = _state.copyWith(
      currentFile: result,
      saturation: value,
      undoStack: [..._state.undoStack, _state.currentFile!],
    );
    _setProcessing(false);
  }

  Future<void> applyFilter(String filterName) async {
    if (_state.originalFile == null) return;
    _setProcessing(true);
    final result =
        await _service.applyFilter(_state.originalFile!, filterName);
    _state = _state.copyWith(
      currentFile: result,
      activeFilter: filterName,
      undoStack: [..._state.undoStack, _state.currentFile!],
    );
    _setProcessing(false);
  }

  Future<void> cropPhoto(String ratio) async {
    if (_state.currentFile == null) return;
    _setProcessing(true);
    final result = await _service.cropPhoto(_state.currentFile!, ratio);
    if (result != null) {
      _state = _state.copyWith(
        currentFile: result,
        undoStack: [..._state.undoStack, _state.currentFile!],
      );
    }
    _setProcessing(false);
  }

  Future<void> rotatePhoto(int degrees) async {
    if (_state.currentFile == null) return;
    _setProcessing(true);
    final result =
        await _service.rotatePhoto(_state.currentFile!, degrees);
    _state = _state.copyWith(
      currentFile: result,
      undoStack: [..._state.undoStack, _state.currentFile!],
    );
    _setProcessing(false);
  }

  Future<void> flipPhoto(String direction) async {
    if (_state.currentFile == null) return;
    _setProcessing(true);
    final result = await _service.flipPhoto(_state.currentFile!, direction);
    _state = _state.copyWith(
      currentFile: result,
      undoStack: [..._state.undoStack, _state.currentFile!],
    );
    _setProcessing(false);
  }

  Future<void> addTextOverlay(TextOverlayItem item) async {
    if (_state.currentFile == null) return;
    _setProcessing(true);
    final result = await _service.addTextOverlay(
      _state.currentFile!,
      item.text,
      item.x,
      item.y,
      item.fontSize,
      item.color,
    );
    _state = _state.copyWith(
      currentFile: result,
      textOverlays: [..._state.textOverlays, item],
      undoStack: [..._state.undoStack, _state.currentFile!],
    );
    _setProcessing(false);
  }

  void undo() {
    if (_state.undoStack.isEmpty) return;
    final prev = _state.undoStack.last;
    final newStack = [..._state.undoStack]..removeLast();
    _state = _state.copyWith(currentFile: prev, undoStack: newStack);
    notifyListeners();
  }

  void reset() {
    if (_state.originalFile == null) return;
    _state = PhotoEditState(
      originalFile: _state.originalFile,
      currentFile: _state.originalFile,
    );
    notifyListeners();
  }

  Future<bool> saveToGallery() async {
    if (_state.currentFile == null) return false;
    return await _service.saveToGallery(_state.currentFile!);
  }

  void _setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }
}
