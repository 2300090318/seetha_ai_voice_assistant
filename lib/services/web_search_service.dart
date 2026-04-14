import 'package:url_launcher/url_launcher.dart';

class WebSearchService {
  Future<bool> searchDuckDuckGo(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://duckduckgo.com/?q=$encodedQuery');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}
