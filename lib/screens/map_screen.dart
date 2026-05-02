import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // Sử dụng thư viện Mapbox mới
import '../widgets/glass_card.dart';
import 'map_precipitation_screen.dart';
import '../logic/shared_nav_bar.dart';

class WeatherDisplayData {
  final int temp, tempMax, tempMin, humidity, pressure;
  final String windSpeed, visibility, cityName;
  final double rain;

  WeatherDisplayData.fromMap(Map<String, dynamic>? data)
    : temp = (data?['main']?['temp'] ?? 0).toInt(),
      tempMax = (data?['main']?['temp_max'] ?? 0).toInt(),
      tempMin = (data?['main']?['temp_min'] ?? 0).toInt(),
      humidity = data?['main']?['humidity'] ?? 0,
      pressure = data?['main']?['pressure'] ?? 0,
      cityName = data?['name'] ?? "BẢN ĐỒ",
      windSpeed = (data?['wind']?['speed'] ?? 0).toString(),
      visibility = ((data?['visibility'] ?? 0) / 1000).toStringAsFixed(1),
      rain = (data?['rain']?['1h'] ?? 0.0).toDouble();
}

class MapScreen extends StatefulWidget {
  final Map<String, dynamic>? weatherData;

  const MapScreen({super.key, this.weatherData});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  // 1. Khai báo Mapbox Controller bản mới
  MapboxMap? _mapboxMap;
  WeatherDisplayData? _data;
  double _lat = 10.8231;
  double _lon = 106.6297;
  late final Widget _mapWidget;
  late final CameraOptions _initialCamera;
  final Stopwatch _mapWatch = Stopwatch();
  @override
  bool get wantKeepAlive => true;
  // --- HÀM ĐIỀU KHIỂN MAPBOX ---

  void _onMapCreated(MapboxMap mapboxMap) {
     debugPrint(
    'MAP CREATED after ${_mapWatch.elapsedMilliseconds} ms',
  );
    if (_mapboxMap != null) return;

    _mapboxMap = mapboxMap;

    _mapboxMap!.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
  }

  void _handleZoom(bool isZoomIn) async {
  if (_mapboxMap == null) return;

  final cameraState = await _mapboxMap!.getCameraState();
  final currentZoom = cameraState.zoom;

  _mapboxMap!.setCamera(
    CameraOptions(
      zoom: isZoomIn ? currentZoom + 1 : currentZoom - 1,
    ),
  );
}

  void _goToDefaultLocation() {
    _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(_lon, _lat)),
        zoom: 13.0,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  @override
  void initState() {
    super.initState();
    // Đợi 500ms sau khi màn hình dựng xong mới bắt đầu load map
    _mapWatch.start();
    // Khởi tạo data ngay tại initState để có sẵn dữ liệu trước khi build
    if (widget.weatherData != null) {
      _data = WeatherDisplayData.fromMap(widget.weatherData);

      if (widget.weatherData!['coord'] != null) {
        _lat = widget.weatherData!['coord']['lat']?.toDouble() ?? _lat;
        _lon = widget.weatherData!['coord']['lon']?.toDouble() ?? _lon;
      }
    }
    _initialCamera = CameraOptions(
      center: Point(coordinates: Position(_lon, _lat)),
      zoom: 11.0,
    );
     _mapWidget = RepaintBoundary(
    child: MapWidget(
      key: const ValueKey('weather-map'),
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: _initialCamera,
      onMapCreated: _onMapCreated,
       onStyleLoadedListener: (_) {
      debugPrint(
        'STYLE LOADED after ${_mapWatch.elapsedMilliseconds} ms',
      );
    },
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Mapping dữ liệu thời tiết
    final main = widget.weatherData?['main'] ?? {};
    final cityName = widget.weatherData?['name'] ?? "BẢN ĐỒ";
    if (_data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Gán data để dùng trong build
    final data = _data!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          cityName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 2. THAY THẾ GOOGLE MAPS BẰNG MAPBOX WIDGET
          MapWidget(
            //key: const ValueKey("mapWidget"),
            styleUri: MapboxStyles.DARK,
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(_lon, _lat)),
              zoom: 11.0,
            ),
          ),

          // Lớp màu Gradient phủ radar nhiệt (Giữ nguyên)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, -0.1),
                  radius: 1.5,
                  colors: [
                    Colors.deepOrange.withOpacity(0.3),
                    Colors.amber.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. GIAO DIỆN CÁC THẺ (Giữ nguyên logic của bạn)
          RepaintBoundary(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                //physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Tabs
                    GlassCard(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggleButton("Nhiệt độ", true),
                          _buildToggleButton("Lượng mưa", false),
                          _buildToggleButton("Gió", false),
                        ],
                      ),
                    ),

                    // Controls
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            _buildMapControlButton(
                              Icons.add,
                              () => _handleZoom(true),
                            ),
                            const SizedBox(height: 10),
                            _buildMapControlButton(
                              Icons.remove,
                              () => _handleZoom(false),
                            ),
                            const SizedBox(height: 10),
                            _buildMapControlButton(
                              Icons.my_location,
                              _goToDefaultLocation,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    _buildMainCard(
                      _data!.temp,
                      _data!.tempMax,
                      _data!.tempMin,
                      25,
                    ), // Fix feelsLike tạm thời
                    const SizedBox(height: 15),
                    _buildStatsGrid(_data!.humidity, 10),
                    const SizedBox(height: 15),
                    _buildHorizontalCard(
                      Icons.speed,
                      "ÁP SUẤT",
                      "${_data!.pressure} hPa",
                    ),
                    const SizedBox(height: 15),
                    _buildHorizontalCard(
                      Icons.umbrella,
                      "LƯỢNG MƯA",
                      "${_data!.rain} mm",
                      subText: _data!.rain > 0 ? "Đang có mưa" : "Không có mưa",
                    ),
                    const SizedBox(height: 120), // Khoảng trống cho Nav Bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SharedNavBar(currentIndex: 0),
    );
  }

  // --- CÁC WIDGET GIAO DIỆN TÁI CẤU TRÚC LẠI ---

  Widget _buildMainCard(int temp, int max, int min, int feels) {
    return GlassCard(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Icon(
              Icons.cloud,
              size: 180,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "HIỆN TẠI",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_data!.temp}°",
                  style: const TextStyle(
                    fontSize: 85,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const Text(
                  "Ít mây",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "C: ${_data!.tempMax}°  T: ${_data!.tempMin}°",
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                Text(
                  "Cảm giác như $feels°",
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int humidity, int visibility) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.9,
      children: [
        _buildGridCard(
          Icons.water_drop,
          "ĐỘ ẨM",
          "${_data!.humidity}%",
          "Điểm sương 11°",
        ),
        _buildGridCard(
          Icons.sunny,
          "CHỈ SỐ UV",
          "4",
          "Trung bình",
          hasBar: true,
        ),
        _buildGridCard(Icons.air, "GIÓ", "${_data!.windSpeed} m/s", "Tây Bắc"),
        _buildGridCard(
          Icons.visibility,
          "TẦM NHÌN",
          "${_data!.visibility} km",
          "Rất rõ",
        ),
      ],
    );
  }

  Widget _buildGridCard(
    IconData icon,
    String title,
    String val,
    String sub, {
    bool hasBar = false,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white70),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasBar)
            LinearProgressIndicator(
              value: 0.4,
              backgroundColor: Colors.white10,
              color: Colors.orange,
              minHeight: 3,
            ),
          Text(
            sub,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(
    IconData icon,
    String title,
    String val, {
    String? subText,
  }) {
    return GestureDetector(
      onTap: () {
        // KIỂM TRA: Nếu nhấn vào thẻ LƯỢNG MƯA
        if (title == "LƯỢNG MƯA") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapPrecipitationScreen(
                weatherData:
                    widget.weatherData, // Truyền dữ liệu sang màn hình Radar
              ),
            ),
          );
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 26),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  val,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (subText != null)
              Text(
                subText,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.white24,
            ), // Thêm icon mũi tên cho người dùng biết là nhấn được
          ],
        ),
      ),
    );
  }

  Widget _buildMapControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.black : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
