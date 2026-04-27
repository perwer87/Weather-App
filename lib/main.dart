import 'package:flutter/material.dart';
import 'screens/weather_screen.dart';

// Get a free API key at https://openweathermap.org/api
const String _apiKey = '4a586854922c4e3988561c290ec5dc4b';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const WeatherScreen(apiKey: _apiKey),
    );
  }
}
