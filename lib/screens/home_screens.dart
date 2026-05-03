import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';
import '../logic/shared_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _hourlyForecast;
  String _cityName = 'Đang tải...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Widget _getWeatherIcon(String iconCode, {double size = 30}) {
    return Image.network(
      'https://openweathermap.org/img/wn/$iconCode@2x.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.cloud, size: size, color: Colors.white),
    );
  }

  Future<void> _fetchData() async {
    try {
      final position = await _weatherService.getCurrentLocation();
      final city = await _weatherService.getCityName(
        position.latitude,
        position.longitude,
      );

      final results = await Future.wait([
        _weatherService.getCurrentWeather(
          position.latitude,
          position.longitude,
        ),
        _weatherService.getHourlyForecast(
          position.latitude,
          position.longitude,
        ),
      ]);
      //final rawCurrentWeather = results[0] as Map<String, dynamic>;
      final List<dynamic> allForecasts = results[1] as List<dynamic>;
      //final now = DateTime.now();
      final int nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final upcomingForecasts = allForecasts
          .where((item) {
            return item['dt'] > (nowTimestamp - 3600); // Lấy từ hiện tại trở đi
          })
          .take(10)
          .toList();
      setState(() {
        _cityName = city;
        _currentWeather = results[0] as Map<String, dynamic>;
        _hourlyForecast = results[1] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _cityName = 'Lỗi kết nối';
        _isLoading = false;
      });
      debugPrint("Lỗi API: $e");
    }
  }


  String _formatTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('HH:mm').format(date); // Output VD: "15:00"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        _cityName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),
                     
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Giúp căn icon lên trên
                        children: [
                          Text(
                            "${_currentWeather?['main']['temp'].round()}°",
                            style: const TextStyle(
                              fontSize: 90,
                              fontWeight: FontWeight.w200,
                              height: 1.1,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              left: 0,
                            ), // Chỉnh top để icon nằm lùi lên trên
                            child: _getWeatherIcon(
                              _currentWeather?['weather'][0]['icon'],
                              size: 60,
                            ), 
                          ),
                        ],
                      ),

                      // Mô tả (Tiếng Việt)
                      Text(
                        _currentWeather?['weather'][0]['description']
                                .toString()
                                .toUpperCase() ??
                            '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "C: ${_currentWeather?['main']['temp_max'].round()}°   T: ${_currentWeather?['main']['temp_min'].round()}°",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),

                     
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E4364).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.air,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "CHẤT LƯỢNG KHÔNG KHÍ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "42 - Nguy cơ thấp",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: const LinearGradient(
                                    colors: [Colors.cyan, Colors.purple],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Chất lượng không khí tuyệt vời. Thời tiết lý tưởng cho các hoạt động ngoài trời.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                   
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "DỰ BÁO THEO GIỜ",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height:
                            160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          itemCount: _hourlyForecast?.length ?? 0,
                          itemBuilder: (context, index) {
                            final hourData = _hourlyForecast![index];
                            bool isNow = index == 0; // Thẻ đầu tiên là Hiện tại
                            bool isTomorrow(int timestamp) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                timestamp * 1000,
                              );
                              final now = DateTime.now();
                              return date.day != now.day;
                            }

                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(
                                right: 12,
                              ), 
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: isNow
                                    ? const Color.fromARGB(255, 161, 158, 173)
                                    : const Color(0xFF3E4364).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), 
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!isNow && isTomorrow(hourData['dt']))
                                    Text(
                                      DateFormat('dd/MM').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          hourData['dt'] * 1000,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white54,
                                      ), // Ngày nhỏ nằm trên
                                    ),
                                  Text(
                                    isNow
                                        ? "Bây giờ"
                                        : _formatTime(hourData['dt']),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isNow
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  
                                  _getWeatherIcon(
                                    hourData['weather'][0]['icon'],
                                    size: 40,
                                  ),
                                  Text(
                                    "${hourData['main']['temp'].round()}°",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.3,
                          children: [
                            WeatherInfoCard(
                              title: "CẢM GIÁC NHƯ",
                              value:
                                  "${_currentWeather?['main']['feels_like'].round()}°",
                              subtitle: "Gần giống nhiệt độ thực.",
                              icon: Icons.thermostat,
                            ),
                            WeatherInfoCard(
                              title: "ĐỘ ẨM",
                              value: "${_currentWeather?['main']['humidity']}%",
                              subtitle: "Điểm sương hiện tại.",
                              icon: Icons.water_drop,
                            ),
                            WeatherInfoCard(
                              title: "TẦM NHÌN",
                              value:
                                  "${(_currentWeather!['visibility'] / 1000).round()} km",
                              subtitle: "Trời quang mây tạnh.",
                              icon: Icons.visibility,
                            ),
                            WeatherInfoCard(
                              title: "ÁP SUẤT",
                              value:
                                  "${_currentWeather?['main']['pressure']} hPa",
                              subtitle: "Mức áp suất tiêu chuẩn.",
                              icon: Icons.speed,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      // THANH ĐIỀU HƯỚNG BÊN DƯỚI (NAVIGATION BAR)
     //bottomNavigationBar: const SharedNavBar(currentIndex: 0),
    );
  }
}
