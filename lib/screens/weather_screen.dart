import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  final String apiKey;

  const WeatherScreen({super.key, required this.apiKey});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  late final WeatherService _service;

  @override
  void initState() {
    super.initState();
    _service = WeatherService(widget.apiKey);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _service.getWeatherByCity(trimmed);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Color> _gradientColors(String? main) {
    switch (main) {
      case 'Clear':
        return [const Color(0xFF2980B9), const Color(0xFF6DD5FA)];
      case 'Clouds':
        return [const Color(0xFF606c88), const Color(0xFF3f4c6b)];
      case 'Rain':
      case 'Drizzle':
        return [const Color(0xFF373B44), const Color(0xFF4286f4)];
      case 'Thunderstorm':
        return [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];
      case 'Snow':
        return [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)];
      case 'Mist':
      case 'Fog':
      case 'Haze':
        return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
      default:
        return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)];
    }
  }

  IconData _weatherIcon(String? main) {
    switch (main) {
      case 'Clear':
        return Icons.wb_sunny_rounded;
      case 'Clouds':
        return Icons.cloud_rounded;
      case 'Rain':
      case 'Drizzle':
        return Icons.grain_rounded;
      case 'Thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'Snow':
        return Icons.ac_unit_rounded;
      case 'Mist':
      case 'Fog':
      case 'Haze':
        return Icons.water_rounded;
      default:
        return Icons.cloud_queue_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _gradientColors(_weather?.main);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search city...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.8)),
            suffixIcon: IconButton(
              icon: Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.8)),
              onPressed: () => _fetchWeather(_searchController.text),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _fetchWeather,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white.withValues(alpha: 0.7), size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_weather == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_queue_rounded, color: Colors.white.withValues(alpha: 0.4), size: 100),
            const SizedBox(height: 20),
            Text(
              'Search for a city\nto see the weather',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 18,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return _buildWeatherDisplay(_weather!);
  }

  Widget _buildWeatherDisplay(WeatherModel weather) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            '${weather.cityName}, ${weather.country}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),
          Icon(
            _weatherIcon(weather.main),
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '${weather.temperature.round()}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.w200,
            ),
          ),
          Text(
            weather.description.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'H:${weather.tempMax.round()}°  L:${weather.tempMin.round()}°',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
          ),
          const SizedBox(height: 36),
          _buildStatsRow(weather),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WeatherModel weather) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(Icons.water_drop_outlined, '${weather.humidity}%', 'Humidity'),
          _buildDivider(),
          _buildStat(Icons.air_rounded, '${weather.windSpeed.toStringAsFixed(1)} m/s', 'Wind'),
          _buildDivider(),
          _buildStat(Icons.thermostat_rounded, '${weather.feelsLike.round()}°C', 'Feels like'),
          _buildDivider(),
          _buildStat(
            Icons.visibility_rounded,
            '${(weather.visibility / 1000).toStringAsFixed(1)} km',
            'Visibility',
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.2));
  }
}
