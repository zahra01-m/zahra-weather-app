class WeatherData {
  final double temp;
  final double feelsLike;
  final String condition;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final String cityName;
  final DateTime sunrise;
  final DateTime sunset;
  final int aqi;
  final List<ForecastDay> forecast;
  final List<HourlyForecast> hourly;

  WeatherData({
    required this.temp,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.cityName,
    required this.sunrise,
    required this.sunset,
    required this.aqi,
    required this.forecast,
    required this.hourly,
  });

  factory WeatherData.fromJson(Map<String, dynamic> current, Map<String, dynamic> forecastData, int aqiIndex) {
    final currentMain = current['main'];
    final currentWeather = current['weather'][0];
    final currentWind = current['wind'];
    final currentSys = current['sys'];

    List<ForecastDay> forecastList = [];
    if (forecastData['list'] != null) {
      // Group by day for 5-day forecast
      Map<String, List<dynamic>> grouped = {};
      for (var item in forecastData['list']) {
        String date = item['dt_txt'].split(' ')[0];
        grouped.putIfAbsent(date, () => []).add(item);
      }

      grouped.forEach((date, items) {
        if (forecastList.length < 5) {
          double min = 1000;
          double max = -1000;
          for (var i in items) {
            double tMin = i['main']['temp_min'].toDouble();
            double tMax = i['main']['temp_max'].toDouble();
            if (tMin < min) min = tMin;
            if (tMax > max) max = tMax;
          }
          forecastList.add(ForecastDay(
            date: DateTime.parse(date),
            minTemp: min,
            maxTemp: max,
            condition: items[0]['weather'][0]['main'],
            icon: items[0]['weather'][0]['icon'],
          ));
        }
      });
    }

    List<HourlyForecast> hourlyList = [];
    if (forecastData['list'] != null) {
      for (var i = 0; i < 8; i++) { // Next 24 hours (3h increments)
        var item = forecastData['list'][i];
        hourlyList.add(HourlyForecast(
          time: DateTime.parse(item['dt_txt']),
          temp: item['main']['temp'].toDouble(),
          icon: item['weather'][0]['icon'],
        ));
      }
    }

    return WeatherData(
      temp: currentMain['temp'].toDouble(),
      feelsLike: currentMain['feels_like'].toDouble(),
      condition: currentWeather['main'],
      description: currentWeather['description'],
      icon: currentWeather['icon'],
      humidity: currentMain['humidity'],
      windSpeed: currentWind['speed'].toDouble(),
      pressure: currentMain['pressure'],
      visibility: current['visibility'] ?? 0,
      cityName: current['name'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(currentSys['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(currentSys['sunset'] * 1000),
      aqi: aqiIndex,
      forecast: forecastList,
      hourly: hourlyList,
    );
  }
}

class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final String icon;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.icon,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temp;
  final String icon;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.icon,
  });
}
