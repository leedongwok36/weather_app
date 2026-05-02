import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../widgets/glass_card.dart';
import '../logic/mapbox_radar_source.dart';

enum RadarMode { precipitation, wind }

class MapPrecipitationScreen extends StatefulWidget {
  final Map<String, dynamic>? weatherData;
  const MapPrecipitationScreen({super.key, this.weatherData});

  @override
  State<MapPrecipitationScreen> createState() => _MapPrecipitationScreenState();
}

class _MapPrecipitationScreenState extends State<MapPrecipitationScreen> {
  //MapboxMap? _mapboxMap;
  MapboxRadarManager? _radarManager;
  double _lat = 10.9805;
  double _lon = 106.6515;
  bool _isMapInitialized = false;
  bool _isRadarStarting = false;

  late final CameraOptions _initialCamera;

  RadarMode _selectedRadarMode = RadarMode.precipitation;
  @override
  void initState() {
    super.initState();
    if (widget.weatherData != null && widget.weatherData!['coord'] != null) {
      _lat = widget.weatherData!['coord']['lat']?.toDouble() ?? _lat;
      _lon = widget.weatherData!['coord']['lon']?.toDouble() ?? _lon;
    }
    _initialCamera = CameraOptions(
      center: Point(coordinates: Position(_lon, _lat)),
      zoom: 11.0,
    );
  }

  // Khi bản đồ khởi tạo xong
 Future<void> _onMapCreated(MapboxMap mapboxMap) async  {
    if (_isMapInitialized) return;
    //_mapboxMap = mapboxMap;
    const String apiKey = '434d9d5e3c9d31058b57e29ce7475d25';
    _radarManager = MapboxRadarManager(mapboxMap, apiKey);
    await _radarManager!.initRadarSources();
    _isMapInitialized = true;
    setState(() => _isMapInitialized = true);
    _startPrecipitationRadar();
  }

  // --- Logic Radar Mapbox ---
 Future<void> _startPrecipitationRadar() async {
  if (!_isMapInitialized || _radarManager == null || _isRadarStarting) return;

  _isRadarStarting = true;

  try {
    await _radarManager!.stopAnimation();
    await _radarManager!.startAnimation();
  } finally {
    _isRadarStarting = false;
  }
}

Future<void> _startWindRadar() async {
  if (!_isMapInitialized || _radarManager == null || _isRadarStarting) return;

  _isRadarStarting = true;

  try {
    await _radarManager!.stopAnimation();

    debugPrint("Start Wind Radar");

    await _radarManager!.startAnimation();
  } finally {
    _isRadarStarting = false;
  }
}

  @override
  void dispose() {
    _radarManager?.stopAnimation(); // Dừng khi thoát màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tối ưu dữ liệu thực tế (Lượng mưa, Gió, Độ ẩm)
    final rain = widget.weatherData?['rain']?['1h'] ?? 0.0;
    final rainAccum24h = (rain * 2.1).toStringAsFixed(1); // Giả lập acumul 24h
    final wind = widget.weatherData?['wind']?['speed'] ?? 0.0;
    final humidity = widget.weatherData?['main']?['humidity'] ?? 0;
    final temp = widget.weatherData?['main']?['temp']?.round() ?? 0;
    final rainChance = (rain * 100).toInt().clamp(
      0,
      100,
    ); // Giả lập tỷ lệ mưa dựa trên lượng mưa

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "RADAR THỜI TIẾT",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // BẢN ĐỒ MAPBOX CÓ RADA
          RepaintBoundary(
            child: MapWidget(
              key: const ValueKey("mapWidget"),
              styleUri:
                  MapboxStyles.DARK, // Dùng Dark Style chuẩn để Radar nổi bật
              onMapCreated: _onMapCreated,
              cameraOptions: _initialCamera,
            ),
          ),

          // PHẦN UI - CÁC GLASS CARD GIỐNG HỆT HÌNH
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // GLASS CARD CHÍNH: LƯỢNG MƯA & GIÓ (Có Tab nhấn được)
                  _buildPrecipitationWindCard(temp, rain, wind),

                  const SizedBox(height: 20),

                  // CỘT CHÍNH (Layout giống hình bạn gửi)
                  if (_selectedRadarMode == RadarMode.precipitation)
                    _buildPrecipitationColumns(
                      rainChance,
                      24.1,
                      rainAccum24h,
                      humidity,
                    )
                  else
                    const Column(
                      children: [
                        Text(
                          "GIAO DIỆN GIÓ (CẦN CODE THÊM)",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // PRECIPITATION TIMELINE (Dữ liệu thực tế)
                  _buildPrecipitationTimeline(rain),

                  const SizedBox(height: 120), // Khoảng trống BottomNav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  // Glass Card lớn ở trên cùng, có Tab "Precipitation" và "Wind" (Hiệu ứng khi nhấn)
  Widget _buildPrecipitationWindCard(int temp, double rain, double wind) {
    return GlassCard(
      width: double.infinity,
      child: Column(
        children: [
          // Phần Tab (Nơi xử lý nhấn để hiện Radar Mapbox)
          Row(
            children: [
              _buildRadarTab(
                icon: Icons.umbrella,
                title: "Precipitation",
                data: "$rain\"", // Đơn vị inch
                isSelected: _selectedRadarMode == RadarMode.precipitation,
                onTap: () {
                  setState(() => _selectedRadarMode = RadarMode.precipitation);
                  _startPrecipitationRadar(); // Gọi logic Radar Lượng mưa Mapbox
                },
              ),
              _buildRadarTab(
                icon: Icons.air,
                title: "Wind",
                data: "$wind MPH", // Đơn vị MPH
                isSelected: _selectedRadarMode == RadarMode.wind,
                onTap: () {
                  setState(() => _selectedRadarMode = RadarMode.wind);
                  _startWindRadar(); // Gọi logic Radar Gió Mapbox
                },
              ),
            ],
          ),

          // Phần nhiệt độ thực tế của Card
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text(
                  "CURRENT PRECIPITATION",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  "$rain\"",
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.water_drop,
                      color: Color(0xFFACAEFF),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      rain > 0 ? "Moderate Rainfall" : "No Rainfall",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget con cho Tab trong Glass Card chính (Có hiệu ứng mờ trắng khi chọn)
  Widget _buildRadarTab({
    required IconData icon,
    required String title,
    required String data,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            // Hiệu ứng mờ trắng như bạn yêu cầu ở ảnh cũ
            color: isSelected
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(isSelected ? 20 : 0),
            border: isSelected ? Border.all(color: Colors.white10) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white60,
                size: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LƯỚI 4 CỘT DỮ LIỆU GIỐNG HỆT HÌNH
  Widget _buildPrecipitationColumns(
    int chanceOfRain,
    double intensityVal,
    String accumulationVal,
    int humidityVal,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatColCard(
              Icons.umbrella,
              "CHANCE OF RAIN",
              "$chanceOfRain%",
              progressBarVal: chanceOfRain / 100,
            ),
            const SizedBox(width: 15),
            _buildStatColCard(
              Icons.air,
              "INTENSITY",
              "$intensityVal in/hr",
              subText: "Steady Rainfall",
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildStatColCard(
              Icons.save,
              "24H ACCUM.",
              "$accumulationVal\"",
              subText: "+0.2\" from avg",
            ),
            const SizedBox(width: 15),
            _buildStatColCard(
              Icons.water_drop,
              "HUMIDITY",
              "$humidityVal%",
              segmentedBarVal: (humidityVal / 25).toInt().clamp(0, 3),
            ),
          ],
        ),
      ],
    );
  }

  // Widget con cho 4 thẻ cột dữ liệu (Có ProgressBar và SegmentedBar)
  Widget _buildStatColCard(
    IconData icon,
    String title,
    String val, {
    String? subText,
    double? progressBarVal,
    int? segmentedBarVal,
  }) {
    return Expanded(
      child: GlassCard(
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
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Thanh Progress chuẩn hình (từ 0.0 đến 1.0)
            if (progressBarVal != null)
              LinearProgressIndicator(
                value: progressBarVal,
                backgroundColor: Colors.white10,
                color: Colors.blue,
                minHeight: 4,
              ),

            // Thanh Segmented chuẩn hình (từ 0 đến 3)
            if (segmentedBarVal != null) _buildSegmentedBar(segmentedBarVal),

            if (subText != null)
              Text(
                subText,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  // Segmented Bar cho Độ ẩm chuẩn hình ảnh
  Widget _buildSegmentedBar(int filledSegments) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index <= filledSegments ? Colors.blue : Colors.white10,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }

  // PRECIPITATION TIMELINE (Dữ liệu thực tế, chuẩn bố cục hình)
  Widget _buildPrecipitationTimeline(double rainVal) {
    return GlassCard(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Precipitation Timeline",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildTimelineItem("Now", rainVal),
          const SizedBox(height: 10),
          _buildTimelineItem("1 PM", rainVal * 0.7), // Giả lập timeline
          const SizedBox(height: 10),
          _buildTimelineItem("2 PM", rainVal * 0.1), // Giả lập timeline
        ],
      ),
    );
  }

  // Widget con cho Timeline Item (Có Bar ProgressBar chuẩn hình)
  Widget _buildTimelineItem(String time, double rainVal) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            time,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 25, // Thanh Timeline chuẩn bố cục
            child: LinearProgressIndicator(
              value: rainVal.clamp(0, 1) / 1, // Dữ liệu thực tế cho Bar
              backgroundColor: Colors.white.withOpacity(
                0.05,
              ), // Màu nền chuẩn bố cục
              color: const Color(0xFF6A6A92), // Màu Progress chuẩn hình
              borderRadius: BorderRadius.circular(8), // Bo góc giống hình
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "${rainVal.toStringAsFixed(1)}\"",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
