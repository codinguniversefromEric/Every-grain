with open("lib/services/background_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("isInDebugMode: false,", "")
content = content.replace("NetworkType.not_required", "NetworkType.notRequired")

with open("lib/services/background_service.dart", "w", encoding="utf-8") as f:
    f.write(content)

with open("lib/widgets/widget_scenery_snapshot.dart", "r", encoding="utf-8") as f:
    content = f.read()

old_metrics = """              weatherMetrics: WeatherMetrics(
                temperature: 25.0,
                humidity: 70.0,
                cloudCover: state.weatherCondition == WeatherCondition.clear ? 10.0 : 80.0,
                isRaining: state.weatherCondition == WeatherCondition.rainy || state.weatherCondition == WeatherCondition.stormy,
                isStormy: state.weatherCondition == WeatherCondition.stormy,
                isCloudy: state.weatherCondition == WeatherCondition.cloudy,
              ),"""

new_metrics = """              weatherMetrics: WeatherMetrics(
                temperature: 25.0,
                humidity: 70.0,
                windSpeed: state.weatherCondition == WeatherCondition.stormy ? 20.0 : 5.0,
                windDirection: 0.0,
                cloudCoverPercentage: state.weatherCondition == WeatherCondition.clear ? 10.0 : 80.0,
                precipitationIntensity: (state.weatherCondition == WeatherCondition.rainy || state.weatherCondition == WeatherCondition.stormy) ? 10.0 : 0.0,
              ),"""

content = content.replace(old_metrics, new_metrics)

with open("lib/widgets/widget_scenery_snapshot.dart", "w", encoding="utf-8") as f:
    f.write(content)
