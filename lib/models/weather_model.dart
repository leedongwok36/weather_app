class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String mainCondition; // Ví dụ: Cloud, Rain
  final String description;   // Ví dụ: Partly cloudy
  final String iconCode;      // Mã icon từ API (01d, 02n...)
  final int humidity;
  final double visibility;    // Đơn vị mét
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

  // Factory constructor để chuyển đổi từ JSON sang Object
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      // API OpenWeather trả về double nhưng đôi khi là int, 
      // dùng .toDouble() để tránh lỗi crash kiểu dữ liệu
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      
      // Dữ liệu weather là một List, ta lấy phần tử đầu tiên
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

  // --- THÊM CÁC BIẾN MỚI CẦN CHO GIAO DIỆN HÌNH ---
  late int rainProbability; // % Tỷ lệ mưa (0-100)
  late double rainAccum24h; // Lượng mưa tích tụ 24h
  late double rainIntensity; // Cường độ mưa (in/hr)

  WeatherDisplayData.fromMap(Map<String, dynamic>? data)
      : temp = (data?['main']?['temp'] ?? 0).toInt(),
        humidity = data?['main']?['humidity'] ?? 0,
        rain = (data?['rain']?['1h'] ?? 0.0).toDouble(), // Lượng mưa thực tế
        cityName = data?['name'] ?? "BẢN ĐỒ",
        windMPH = ((data?['wind']?['speed'] ?? 0) * 2.23694).toDouble() // Chuyển sang MPH (dữ liệu thực)
  {
    // --- LOGIC GIẢ LẬP DỮ LIỆU (Vì API Free không cung cấp) ---
    // Logic này sẽ giúp Grid 4 cột có dữ liệu nhảy theo lượng mưa thực tế
    if (rain > 0) {
      rainProbability = (rain * 200).toInt().clamp(10, 95); // Lượng mưa càng nhiều, tỷ lệ càng cao
      rainIntensity = rain; // Dùng chung Lượng mưa 1h
      rainAccum24h = rain * 3.5; // Giả lập accumulation
    } else {
      // Dữ liệu khi không có mưa (giả lập giống hình)
      rainProbability = (data?['clouds']?['all'] ?? 5).toInt().clamp(5, 40); // Theo mây
      rainAccum24h = 0.0;
      rainIntensity = 0.0;
    }
  }
}