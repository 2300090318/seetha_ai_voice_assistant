import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import '../utils/ffmpeg_helper.dart';

class VideoEditService {
  // ─── Pick Video ─────────────────────────────────────────────────────────────
  Future<File?> pickVideo() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return null;

    final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
    if (albums.isEmpty) return null;

    final assets = await albums.first.getAssetListRange(start: 0, end: 1);
    if (assets.isEmpty) return null;

    return await assets.first.file;
  }

  // ─── Trim Video ─────────────────────────────────────────────────────────────
  Future<File?> trimVideo(
    File video,
    Duration start,
    Duration end, {
    ProgressCallback? onProgress,
  }) async {
    final startStr = _formatDuration(start);
    final toStr = _formatDuration(end);
    final durationMs = (end.inMilliseconds - start.inMilliseconds).toDouble();

    final outPath = await FfmpegHelper.getTempOutputPath('mp4');
    final command = '-ss $startStr -to $toStr -i "${video.path}" -c copy';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
      totalDurationMs: durationMs > 0 ? durationMs : null,
    );
  }

  // ─── Change Speed ───────────────────────────────────────────────────────────
  Future<File?> changeSpeed(
    File video,
    double speed, {
    ProgressCallback? onProgress,
  }) async {
    final atempo = speed.clamp(0.5, 2.0); // Simple atempo limit for demo
    final setpts = 1.0 / speed;
    
    final outPath = await FfmpegHelper.getTempOutputPath('mp4');
    final command =
        '-i "${video.path}" -filter_complex "[0:v]setpts=${setpts}*PTS[v];[0:a]atempo=$atempo[a]" -map "[v]" -map "[a]"';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
    );
  }

  // ─── Mute Video ─────────────────────────────────────────────────────────────
  Future<File?> muteVideo(
    File video, {
    ProgressCallback? onProgress,
  }) async {
    final outPath = await FfmpegHelper.getTempOutputPath('mp4');
    final command = '-i "${video.path}" -c:v copy -an';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
    );
  }

  // ─── Add Music ──────────────────────────────────────────────────────────────
  Future<File?> addMusic(
    File video,
    File music, {
    ProgressCallback? onProgress,
  }) async {
    final outPath = await FfmpegHelper.getTempOutputPath('mp4');
    final command =
        '-i "${video.path}" -i "${music.path}" -c:v copy -map 0:v:0 -map 1:a:0 -shortest';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
    );
  }

  // ─── Compress Video ─────────────────────────────────────────────────────────
  Future<File?> compressVideo(
    File video,
    String quality, {
    ProgressCallback? onProgress,
  }) async {
    String crf;
    switch (quality.toLowerCase()) {
      case 'high':
        crf = '18';
        break;
      case 'medium':
        crf = '28';
        break;
      case 'low':
        crf = '35';
        break;
      default:
        crf = '28';
    }

    final outPath = await FfmpegHelper.getTempOutputPath('mp4');
    final command = '-i "${video.path}" -vcodec libx264 -crf $crf';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
    );
  }

  // ─── Add Watermark ──────────────────────────────────────────────────────────
  Future<File?> addWatermark(
    File video,
    String text,
    String position, {
    ProgressCallback? onProgress,
  }) async {
    String xy;
    switch (position.toLowerCase()) {
      case 'topleft':
        xy = 'x=10:y=10';
        break;
      case 'topright':
        xy = 'x=w-tw-10:y=10';
        break;
      case 'bottomleft':
        xy = 'x=10:y=h-th-10';
        break;
      case 'bottomright':
      default:
        xy = 'x=w-tw-10:y=h-th-10';
        break;
    }

    final outPath = await FfmpegHelper.getTempOutputPath('mp4');
    final command =
        '-i "${video.path}" -vf "drawtext=text=\'$text\':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:$xy" -codec:a copy';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
    );
  }

  // ─── Apply Fade ─────────────────────────────────────────────────────────────
  Future<File?> addFade(
    File video,
    bool fadeIn,
    bool fadeOut, {
    ProgressCallback? onProgress,
  }) async {
    // Requires knowing duration for fade out out of scope for a simple call
    // For demo, just fade in for 2 seconds.
    final outPath = await FfmpegHelper.getTempOutputPath('mp4');
    String filter = '';
    if (fadeIn) filter += 'fade=t=in:st=0:d=2';
    // fadeOut is trickier without probing length first, ignoring for simple mock
    if (filter.isEmpty) filter = 'copy';

    final command =
        '-i "${video.path}" -vf "$filter" -c:a copy';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
    );
  }

  // ─── Merge Videos ───────────────────────────────────────────────────────────
  Future<File?> mergeVideos(
    List<File> videos, {
    ProgressCallback? onProgress,
  }) async {
    if (videos.length < 2) return null;
    
    // Create a concat text file
    final tempDir = await FfmpegHelper.getTempOutputPath('txt');
    final concatFile = File(tempDir);
    String concatContent = '';
    for (var v in videos) {
      concatContent += 'file \'${v.path}\'\n';
    }
    await concatFile.writeAsString(concatContent);

    final outPath = await FfmpegHelper.getTempOutputPath('mp4');
    final command = '-f concat -safe 0 -i "${concatFile.path}" -c copy';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
    );
  }

  // ─── Extract Audio ──────────────────────────────────────────────────────────
  Future<File?> extractAudio(
    File video, {
    ProgressCallback? onProgress,
  }) async {
    final outPath = await FfmpegHelper.getTempOutputPath('mp3');
    final command = '-i "${video.path}" -q:a 0 -map a';

    return await FfmpegHelper.execute(
      command: command,
      outputFileName: outPath.split('/').last,
      onProgress: onProgress,
    );
  }

  // ─── Save to Gallery ────────────────────────────────────────────────────────
  Future<bool> saveToGallery(File video) async {
    try {
      final asset = await PhotoManager.editor.saveVideo(
        video,
        title: 'SEETHA_VIDEO_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      return asset != null;
    } catch (e) {
      return false;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
