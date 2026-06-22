import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../models/weather_model.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;

  const WeatherIcon({super.key, required this.condition, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Lottie.network(
      _getLottieUrl(condition),
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.wb_cloudy, size: size, color: Colors.white),
    );
  }

  String _getLottieUrl(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear': return 'https://assets5.lottiefiles.com/packages/lf20_xlky4kvh.json';
      case 'clouds': return 'https://assets5.lottiefiles.com/packages/lf20_dg69onv9.json';
      case 'rain': return 'https://assets5.lottiefiles.com/packages/lf20_ih8m0sz9.json';
      case 'snow': return 'https://assets5.lottiefiles.com/packages/lf20_9nS97V.json';
      default: return 'https://assets5.lottiefiles.com/packages/lf20_dg69onv9.json';
    }
  }
}

class DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailCard({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFCF9BE), size: 24), // Using Pale Yellow for icons
          const SizedBox(width: 8),
          Expanded( // Prevents overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label, 
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ForecastItem extends StatelessWidget {
  final ForecastDay day;
  final bool isCelsius;

  const ForecastItem({super.key, required this.day, required this.isCelsius});

  String _formatTemp(double temp) {
    if (!isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return "${temp.toStringAsFixed(1)}°";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              DateFormat('EEEE').format(day.date), 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
            )
          ),
          Row(
            children: [
              Image.network("https://openweathermap.org/img/wn/${day.icon}.png", width: 40),
              const SizedBox(width: 8),
              Text(
                "${_formatTemp(day.maxTemp)} / ${_formatTemp(day.minTemp)}", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HourlyItem extends StatelessWidget {
  final HourlyForecast hourly;
  final bool isCelsius;

  const HourlyItem({super.key, required this.hourly, required this.isCelsius});

  String _formatTemp(double temp) {
    if (!isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return "${temp.toStringAsFixed(0)}°";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('ha').format(hourly.time), style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 5),
          Image.network("https://openweathermap.org/img/wn/${hourly.icon}.png", width: 35),
          const SizedBox(height: 5),
          Text(_formatTemp(hourly.temp), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class WeatherShimmer extends StatelessWidget {
  const WeatherShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(height: 40, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Container(height: 120, width: 120, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(height: 20),
            Container(height: 60, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List.generate(4, (index) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)))),
            ),
          ],
        ),
      ),
    );
  }
}
