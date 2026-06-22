import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/weather_provider.dart';
import 'weather_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _getLocation(WidgetRef ref, BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      await ref.read(weatherProvider.notifier).fetchWeatherByCoords(position.latitude, position.longitude);
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherDetailsScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView( // Prevents pixel overflow
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Hero(
                    tag: 'app_title',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        "Zahra Weather",
                        style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Real-time weather updates & forecasts",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 50),
                  
                  // Search Bar Hero
                  GestureDetector(
                    onTap: () => _showSearch(context, ref),
                    child: Hero(
                      tag: 'search_bar',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 15),
                            Flexible(
                              child: Text(
                                "Search your city...", 
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // GPS Button
                  ElevatedButton.icon(
                    onPressed: () => _getLocation(ref, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCD29B), // Light Orange from palette
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.my_location),
                    label: const Text("Use Current Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 50),

                  // Saved Cities Section
                  if (state.favoriteCities.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Favorite Cities", 
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.favoriteCities.length,
                        itemBuilder: (context, i) {
                          final city = state.favoriteCities[i];
                          return GestureDetector(
                            onTap: () async {
                              await ref.read(weatherProvider.notifier).fetchWeather(city);
                              if (context.mounted) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherDetailsScreen()));
                              }
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCF9BE).withOpacity(0.2), // Pale Yellow from palette
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_city, color: Colors.white, size: 35),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      city, 
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), 
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchSheet(),
    );
  }
}

class SearchSheet extends ConsumerStatefulWidget {
  const SearchSheet({super.key});

  @override
  ConsumerState<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends ConsumerState<SearchSheet> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, // Responsive to keyboard
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 30),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter city name",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
            onSubmitted: (val) async {
              if (val.trim().isNotEmpty) {
                await ref.read(weatherProvider.notifier).fetchWeather(val.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherDetailsScreen()));
                }
              }
            },
          ),
          const SizedBox(height: 30),
          if (state.searchHistory.isNotEmpty) ...[
            const Text("Recent Searches", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: state.searchHistory.map((city) => ActionChip(
                    label: Text(city, style: const TextStyle(color: Colors.black87)),
                    onPressed: () async {
                      await ref.read(weatherProvider.notifier).fetchWeather(city);
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherDetailsScreen()));
                      }
                    },
                    backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  )).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
