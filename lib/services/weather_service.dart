import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<String> getWeather(String city) async {
    try {
      // Step 1: Geocoding
      final geoUrl =
          Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1');
      final geoRes = await http.get(geoUrl);
      if (geoRes.statusCode != 200) return 'I could not find the city $city.';

      final geoData = jsonDecode(geoRes.body);
      if (geoData['results'] == null || geoData['results'].isEmpty) {
        return 'I could not find the city $city.';
      }

      final lat = geoData['results'][0]['latitude'];
      final lon = geoData['results'][0]['longitude'];
      final name = geoData['results'][0]['name'];

      // Step 2: Weather Forecast
      final weatherUrl = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weathercode,windspeed_10m,relativehumidity_2m');
      final weatherRes = await http.get(weatherUrl);
      if (weatherRes.statusCode != 200) return 'I could not retrieve the weather for $name.';

      final weatherData = jsonDecode(weatherRes.body);
      final current = weatherData['current'];
      
      final temp = current['temperature_2m'];
      final humidity = current['relativehumidity_2m'];
      final code = current['weathercode'];

      final condition = _getCondition(code);

      return 'It is $temp degrees in $name. $condition with $humidity percent humidity.';
    } catch (e) {
      return 'I am having trouble checking the weather right now.';
    }
  }

  String _getCondition(int code) {
    if (code == 0) return 'Clear skies';
    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzling';
    if (code >= 61 && code <= 65) return 'Raining';
    if (code >= 71 && code <= 75) return 'Snowing';
    if (code >= 95) return 'Thunderstorms';
    return 'Mixed conditions';
  }
}
