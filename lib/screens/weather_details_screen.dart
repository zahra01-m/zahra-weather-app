import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_widgets.dart';

class WeatherDetailsScreen extends ConsumerStatefulWidget {
  const WeatherDetailsScreen({super.key});

  @override
  ConsumerState<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends ConsumerState<WeatherDetailsScreen> {
  void _shareWeather(weather) {
    final text = "Current weather in ${weather.cityName}: ${weather.temp}°C, ${weather.condition}. Shared via Zahra Weather App.";
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final weather = state.weather;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Hero(
          tag: 'app_title',
          child: Material(
            color: Colors.transparent,
            child: Text("Weather Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(state.isCelsius ? Icons.thermostat : Icons.ac_unit, color: Colors.white),
            onPressed: () => ref.read(weatherProvider.notifier).toggleUnit(),
          ),
          if (weather != null)
            IconButton(
              icon: Icon(state.favoriteCities.contains(weather.cityName) ? Icons.favorite : Icons.favorite_border, color: Colors.white),
              onPressed: () => ref.read(weatherProvider.notifier).toggleFavorite(weather.cityName),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: state.isLoading 
            ? const Center(child: WeatherShimmer())
            : state.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 60),
                        const SizedBox(height: 10),
                        Text(state.error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                          child: const Text("Go Back"),
                        )
                      ],
                    ),
                  ),
                )
              : weather == null
                ? const Center(child: Text("No data found", style: TextStyle(color: Colors.white)))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Hero(
                            tag: 'city_name_${weather.cityName}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                weather.cityName, 
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          WeatherIcon(condition: weather.condition, size: 140),
                          Text(
                            state.isCelsius ? "${weather.temp.toStringAsFixed(1)}°C" : "${(weather.temp * 9/5 + 32).toStringAsFixed(1)}°F",
                            style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            weather.description.toUpperCase(), 
                            style: const TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.w500),
                          ),
                          
                          const SizedBox(height: 30),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              DetailCard(icon: Icons.water_drop, label: "Humidity", value: "${weather.humidity}%"),
                              DetailCard(icon: Icons.air, label: "Wind", value: "${weather.windSpeed} m/s"),
                              DetailCard(icon: Icons.speed, label: "Pressure", value: "${weather.pressure} hPa"),
                              DetailCard(icon: Icons.visibility, label: "Visibility", value: "${(weather.visibility/1000).toStringAsFixed(1)} km"),
                            ],
                          ),

                          const SizedBox(height: 30),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Hourly Forecast", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: weather.hourly.length,
                              itemBuilder: (context, i) => HourlyItem(hourly: weather.hourly[i], isCelsius: state.isCelsius),
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("5-Day Forecast", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: weather.forecast.length,
                            itemBuilder: (context, i) => ForecastItem(day: weather.forecast[i], isCelsius: state.isCelsius),
                          ),
                          
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () => _shareWeather(weather),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8B8B), // Soft Red/Tertiary
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: const Icon(Icons.share),
                            label: const Text("Share Weather Report", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
