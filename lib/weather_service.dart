import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey;

  WeatherService(this.apiKey);

  Future<double?> getWeather(String cityName) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final temperature =
          data['main']['temp'] - 273.15; // Convert from Kelvin to Celsius
      return temperature;
    } else {
      if (kDebugMode) {
        print('Error: ${json.decode(response.body)['message']}');
      }
      return null;
    }
  }
}
