import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = 'api'; // ĐIỀN API KEY CỦA BẠN VÀO ĐÂY

  // Hàm lấy vị trí hiện tại
  // Lấy vị trí GPS
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Dịch vụ vị trí bị tắt.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Quyền vị trí bị từ chối.');
      }
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getCityName(double lat, double lon) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
    if (placemarks.isNotEmpty) {
      return placemarks[0].locality ?? 'Đang xác định...';
    }
    return 'Không rõ';
  }

  // API 1: Lấy thời tiết HIỆN TẠI (kèm tham số lang=vi để lấy tiếng Việt)
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    final String url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể tải thời tiết hiện tại');
    }
  }

  // API 2: Lấy dự báo thời tiết THEO GIỜ (Bản free là mỗi 3 giờ/lần)
  Future<List<dynamic>> getHourlyForecast(double lat, double lon) async {
    final String url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['list']; // Trả về mảng danh sách dự báo
    } else {
      throw Exception('Không thể tải dự báo theo giờ');
    }
  }
}