class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String mainCondition; 
  final String description;   
  final String iconCode;      
  final int humidity;
  final double visibility;    
  final double windSpeed;
  
  Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.mainCondition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.visibility,
    required this.windSpeed,
  });

 
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
     
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      
     
      mainCondition: json['weather'][0]['main'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '',
      
      humidity: json['main']['humidity'] ?? 0,
      visibility: (json['visibility'] as num).toDouble() / 1000, // Đổi sang km
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}
class WeatherDisplayData {
  final int temp, humidity;
  final double rain, windMPH;
  final String cityName;

 
  late int rainProbability; 
  late double rainAccum24h; 
  late double rainIntensity; 
  WeatherDisplayData.fromMap(Map<String, dynamic>? data)
      : temp = (data?['main']?['temp'] ?? 0).toInt(),
        humidity = data?['main']?['humidity'] ?? 0,
        rain = (data?['rain']?['1h'] ?? 0.0).toDouble(), 
        cityName = data?['name'] ?? "BẢN ĐỒ",
        windMPH = ((data?['wind']?['speed'] ?? 0) * 2.23694).toDouble() 
  {
   
    if (rain > 0) {
      rainProbability = (rain * 200).toInt().clamp(10, 95); 
      rainIntensity = rain; 
      rainAccum24h = rain * 3.5; 
    } else {
      
      rainProbability = (data?['clouds']?['all'] ?? 5).toInt().clamp(5, 40);
      rainAccum24h = 0.0;
      rainIntensity = 0.0;
    }
  }
}
