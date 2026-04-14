import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

typedef ProgressCallback = void Function(double progress);

class FfmpegHelper {
  static Future<File?> execute({
    required String command,
    required String outputFileName,
    ProgressCallback? onProgress,
    double? totalDurationMs,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = p.join(tempDir.path, outputFileName);

    if (onProgress != null && totalDurationMs != null) {
      FFmpegKitConfig.enableStatisticsCallback((Statistics stats) {
        final progress = (stats.getTime() / totalDurationMs).clamp(0.0, 1.0);
        onProgress(progress);
      });
    }

    final session = await FFmpegKit.execute('$command -y "$outputPath"');
    final returnCode = await session.getReturnCode();

    FFmpegKitConfig.disableStatistics();

    if (ReturnCode.isSuccess(returnCode)) {
      return File(outputPath);
    } else {
      final logs = await session.getAllLogsAsString();
      // ignore: avoid_print
      print('FFmpeg error: $logs');
      return null;
    }
  }

  static Future<String> getTempOutputPath(String extension) async {
    final tempDir = await getTemporaryDirectory();
    final name =
        'seetha_${DateTime.now().millisecondsSinceEpoch}.$extension';
    return p.join(tempDir.path, name);
  }
}
