import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PhotoEditService {
  // ─── Pick Photo ─────────────────────────────────────────────────────────────
  Future<File?> pickPhoto() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return null;

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (albums.isEmpty) return null;

    final assets =
        await albums.first.getAssetListRange(start: 0, end: 1);
    if (assets.isEmpty) return null;

    return await assets.first.file;
  }

  // ─── Brightness ─────────────────────────────────────────────────────────────
  Future<File> adjustBrightness(File photo, double value) async {
    final image = img.decodeImage(await photo.readAsBytes())!;
    final adjusted = img.adjustColor(image,
        brightness: 1.0 + (value / 100));
    return _save(img.encodeJpg(adjusted));
  }

  // ─── Contrast ───────────────────────────────────────────────────────────────
  Future<File> adjustContrast(File photo, double value) async {
    final image = img.decodeImage(await photo.readAsBytes())!;
    final adjusted = img.adjustColor(image,
        contrast: 1.0 + (value / 100));
    return _save(img.encodeJpg(adjusted));
  }

  // ─── Saturation ─────────────────────────────────────────────────────────────
  Future<File> adjustSaturation(File photo, double value) async {
    final image = img.decodeImage(await photo.readAsBytes())!;
    final adjusted = img.adjustColor(image,
        saturation: 1.0 + (value / 100));
    return _save(img.encodeJpg(adjusted));
  }

  // ─── Apply Filter ────────────────────────────────────────────────────────────
  Future<File> applyFilter(File photo, String filterName) async {
    final image = img.decodeImage(await photo.readAsBytes())!;
    img.Image result;

    switch (filterName) {
      case 'bw':
        result = img.grayscale(image);
        break;
      case 'sepia':
        result = img.sepia(image);
        break;
      case 'vivid':
        result = img.adjustColor(image, saturation: 1.5, contrast: 1.2);
        break;
      case 'cool':
        result = img.adjustColor(image, hue: 200);
        break;
      case 'warm':
        result = img.adjustColor(image, hue: 30, saturation: 1.2);
        break;
      case 'fade':
        result = img.adjustColor(image, contrast: 0.8, brightness: 1.1);
        break;
      case 'drama':
        result = img.adjustColor(image, contrast: 1.4, saturation: 1.3);
        break;
      case 'chrome':
        result = img.adjustColor(image, contrast: 1.2, saturation: 0.9);
        break;
      case 'noir':
        result = img.grayscale(img.adjustColor(image, contrast: 1.5));
        break;
      default: // original
        result = image;
    }

    return _save(img.encodeJpg(result));
  }

  // ─── Crop ───────────────────────────────────────────────────────────────────
  Future<File?> cropPhoto(File photo, String ratio) async {
    CropAspectRatioPreset preset;
    switch (ratio) {
      case '1:1':
        preset = CropAspectRatioPreset.square;
        break;
      case '4:3':
        preset = CropAspectRatioPreset.ratio4x3;
        break;
      case '16:9':
        preset = CropAspectRatioPreset.ratio16x9;
        break;
      default:
        preset = CropAspectRatioPreset.original;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: photo.path,
      aspectRatioPresets: [preset],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: const Color(0xFF7c3aed),
          toolbarWidgetColor: const Color(0xFFFFFFFF),
          activeControlsWidgetColor: const Color(0xFF7c3aed),
          initAspectRatio: preset,
        ),
      ],
    );
    return cropped != null ? File(cropped.path) : null;
  }

  // ─── Rotate ─────────────────────────────────────────────────────────────────
  Future<File> rotatePhoto(File photo, int degrees) async {
    final image = img.decodeImage(await photo.readAsBytes())!;
    final rotated = img.copyRotate(image, angle: degrees.toDouble());
    return _save(img.encodeJpg(rotated));
  }

  // ─── Flip ───────────────────────────────────────────────────────────────────
  Future<File> flipPhoto(File photo, String direction) async {
    final image = img.decodeImage(await photo.readAsBytes())!;
    img.Image flipped;

    if (direction == 'horizontal') {
      flipped = img.flipHorizontal(image);
    } else {
      flipped = img.flipVertical(image);
    }

    return _save(img.encodeJpg(flipped));
  }

  // ─── Text Overlay ────────────────────────────────────────────────────────────
  Future<File> addTextOverlay(
    File photo,
    String text,
    double x,
    double y,
    double fontSize,
    String color,
  ) async {
    final image = img.decodeImage(await photo.readAsBytes())!;
    final colorValue = _hexToColor(color);

    img.drawString(
      image,
      text,
      font: img.arial48,
      x: x.toInt(),
      y: y.toInt(),
      color: img.ColorRgba8(colorValue.r, colorValue.g, colorValue.b, 255),
    );

    return _save(img.encodeJpg(image));
  }

  // ─── Save to Gallery ────────────────────────────────────────────────────────
  Future<bool> saveToGallery(File photo) async {
    try {
      final asset = await PhotoManager.editor.saveImageWithPath(
        photo.path,
        title: 'SEETHA_${DateTime.now().millisecondsSinceEpoch}',
      );
      return asset != null;
    } catch (e) {
      return false;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  Future<File> _save(List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final path =
        p.join(dir.path, 'seetha_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final file = File(path);
    await file.writeAsBytes(Uint8List.fromList(bytes));
    return file;
  }

  _ColorRGB _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return _ColorRGB(
        int.parse(cleaned.substring(0, 2), radix: 16),
        int.parse(cleaned.substring(2, 4), radix: 16),
        int.parse(cleaned.substring(4, 6), radix: 16),
      );
    }
    return _ColorRGB(255, 255, 255);
  }
}

class Color {
  final int value;
  const Color(this.value);
}

class _ColorRGB {
  final int r, g, b;
  _ColorRGB(this.r, this.g, this.b);
}
