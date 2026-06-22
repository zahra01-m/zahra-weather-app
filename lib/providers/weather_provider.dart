import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

class WeatherState {
  final WeatherData? weather;
  final bool isLoading;
  final String? error;
  final List<String> searchHistory;
  final List<String> favoriteCities;
  final bool isCelsius;

  WeatherState({
    this.weather,
    this.isLoading = false,
    this.error,
    this.searchHistory = const [],
    this.favoriteCities = const [],
    this.isCelsius = true,
  });

  WeatherState copyWith({
    WeatherData? weather,
    bool? isLoading,
    String? error,
    List<String>? searchHistory,
    List<String>? favoriteCities,
    bool? isCelsius,
  }) {
    return WeatherState(
      weather: weather ?? this.weather,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null to clear error
      searchHistory: searchHistory ?? this.searchHistory,
      favoriteCities: favoriteCities ?? this.favoriteCities,
      isCelsius: isCelsius ?? this.isCelsius,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherService _service;
  
  WeatherNotifier(this._service) : super(WeatherState()) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];
    final favorites = prefs.getStringList('favorite_cities') ?? [];
    final isCelsius = prefs.getBool('is_celsius') ?? true;
    state = state.copyWith(
      searchHistory: history,
      favoriteCities: favorites,
      isCelsius: isCelsius,
    );
  }

  Future<void> fetchWeather(String city) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final weather = await _service.fetchWeather(city);
      _addToHistory(city);
      state = state.copyWith(weather: weather, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> fetchWeatherByCoords(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final weather = await _service.fetchWeatherByCoords(lat, lon);
      state = state.copyWith(weather: weather, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void toggleUnit() async {
    final newValue = !state.isCelsius;
    state = state.copyWith(isCelsius: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_celsius', newValue);
  }

  void _addToHistory(String city) async {
    final history = List<String>.from(state.searchHistory);
    if (history.contains(city)) history.remove(city);
    history.insert(0, city);
    if (history.length > 5) history.removeLast();
    
    state = state.copyWith(searchHistory: history);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', history);
  }

  void toggleFavorite(String city) async {
    final favorites = List<String>.from(state.favoriteCities);
    if (favorites.contains(city)) {
      favorites.remove(city);
    } else {
      favorites.add(city);
    }
    state = state.copyWith(favoriteCities: favorites);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_cities', favorites);
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final service = ref.watch(weatherServiceProvider);
  return WeatherNotifier(service);
});
