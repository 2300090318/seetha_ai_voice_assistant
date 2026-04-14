import 'package:url_launcher/url_launcher.dart';

class MusicService {
  Future<bool> playOnSpotify(String songName) async {
    final query = Uri.encodeComponent(songName);
    final spotifySearchUri =
        Uri.parse('spotify:search:$query');
    final webFallback =
        Uri.parse('https://open.spotify.com/search/$query');

    if (await canLaunchUrl(spotifySearchUri)) {
      await launchUrl(spotifySearchUri);
      return true;
    } else if (await canLaunchUrl(webFallback)) {
      await launchUrl(webFallback, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  Future<bool> playOnYouTube(String songName) async {
    final query = Uri.encodeComponent('$songName music');
    final youtubeUri =
        Uri.parse('https://www.youtube.com/results?search_query=$query');
    if (await canLaunchUrl(youtubeUri)) {
      await launchUrl(youtubeUri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  Future<bool> play(String songName, String platform) async {
    switch (platform.toLowerCase()) {
      case 'spotify':
        return await playOnSpotify(songName);
      case 'youtube':
        return await playOnYouTube(songName);
      default:
        // Try Spotify first, fall back to YouTube
        final spotifyResult = await playOnSpotify(songName);
        if (!spotifyResult) return await playOnYouTube(songName);
        return true;
    }
  }
}
