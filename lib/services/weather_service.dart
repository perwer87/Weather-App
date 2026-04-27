import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey;

  const WeatherService(this.apiKey);

  Future<WeatherModel> getWeatherByCity(String city) async {
    final uri = Uri.parse(
      '$_baseUrl/weather?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key');
    } else {
      throw Exception('Failed to fetch weather (${response.statusCode})');
    }
  }
}
