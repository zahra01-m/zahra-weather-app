import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String? _apiKey = dotenv.env['OPENWEATHER_API_KEY'];

  Future<WeatherData> fetchWeather(String city) async {
    final currentUrl = '$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(currentUrl));

    if (response.statusCode == 200) {
      final currentData = json.decode(response.body);
      return _fetchAdditionalData(currentData);
    } else {
      throw Exception('Failed to load weather: ${json.decode(response.body)['message']}');
    }
  }

  Future<WeatherData> fetchWeatherByCoords(double lat, double lon) async {
    final currentUrl = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(currentUrl));

    if (response.statusCode == 200) {
      final currentData = json.decode(response.body);
      return _fetchAdditionalData(currentData);
    } else {
      throw Exception('Failed to load weather: ${json.decode(response.body)['message']}');
    }
  }

  Future<WeatherData> _fetchAdditionalData(Map<String, dynamic> currentData) async {
    final lat = currentData['coord']['lat'];
    final lon = currentData['coord']['lon'];

    // Fetch Forecast
    final forecastUrl = '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final forecastRes = await http.get(Uri.parse(forecastUrl));
    final forecastData = json.decode(forecastRes.body);

    // Fetch AQI
    final aqiUrl = '$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey';
    final aqiRes = await http.get(Uri.parse(aqiUrl));
    final aqiData = json.decode(aqiRes.body);
    final aqiIndex = aqiData['list'][0]['main']['aqi'];

    return WeatherData.fromJson(currentData, forecastData, aqiIndex);
  }
}
