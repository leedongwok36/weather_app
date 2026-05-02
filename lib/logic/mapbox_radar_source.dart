import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// Class quản lý các mốc thời gian và hình ảnh Radar từ Mapbox
class MapboxRadarTimeline {
  final int time;
  final String tileUrl; // Đây là URL Mapbox cung cấp tiles ảnh radar
  final String sourceId;
  final String layerId;

  MapboxRadarTimeline({
    required this.time,
    required this.tileUrl,
    required this.sourceId,
    required this.layerId,
  });

  // Chuyển đổi dữ liệu radar từ API Mapbox thành Model để bản đồ sử dụng
  // Dữ liệu tileUrl thường có dạng: mapbox://tileset-id.v2/{z}/{x}/{y}?time={time}
  // Ở đây chúng ta sẽ giả lập dữ liệu tĩnh để code không bị lỗi.
  // Trong thực tế, bạn cần gọi API Mapbox hoặc một dịch vụ cung cấp dữ liệu Radar OpenWeatherMap
  // để lấy tileUrl thực tế.
}

class MapboxRadarManager {
  final MapboxMap mapboxMap;
  final List<MapboxRadarTimeline> timeline = [];
  int _currentIndex = 0;
  bool _isPlaying = false;

  // Tên Source và Layer để render Radar trên Mapbox (Dark style)
  static const String radarSourceId = "mapbox-precipitation-radar-source";
  static const String radarLayerId = "mapbox-precipitation-radar-layer";
  static const String darkLayerAboveId =
      "tunnel-simple"; // Để radar nằm dưới tên đường và hầm

  MapboxRadarManager(this.mapboxMap, String apiKey) {
    final String radarUrl =
        'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=$apiKey';
   timeline.add(MapboxRadarTimeline(
    time: DateTime.now().millisecondsSinceEpoch,
    tileUrl: radarUrl, 
    sourceId: "owm-radar-source",
    layerId: "owm-radar-layer",
  ));
    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Giả lập 5 mốc dữ liệu
    for (int i = 0; i < 5; i++) {
      timeline.add(
        MapboxRadarTimeline(
          time: now + (i * 300), // Cách nhau 5 phút
          tileUrl:
              'mapbox://styles/mapbox/dark-v11/v2/{z}/{x}/{y}', // CHỈ LÀ TƯỢNG TRƯNG
          sourceId: "$radarSourceId-$i",
          layerId: "$radarLayerId-$i",
        ),
      );
    }
  }

  // Khởi tạo các Sources và Layers radar trên bản đồ
  Future<void> initRadarSources() async {
    for (var timepoint in timeline) {
      // 1. Tạo Source cho hình ảnh radar
      // Trong Flutter, chúng ta dùng RasterTileSource
      final rasterSource = RasterSource(
        id: timepoint.sourceId,
        tiles: ['https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=434d9d5e3c9d31058b57e29ce7475d25'], // Truyền URL tiles vào đây
        tileSize: 256,
        // tileSize: 256,
        // Dữ liệu thực tế cần truyền URL Mapbox vào đây:
        // tiles: [timepoint.tileUrl],
      );
      // Chèn source vào style (bắt lỗi nếu đã tồn tại)
      try {
        await mapboxMap.style.addSource(rasterSource);
      } catch (e) {
        print("Radar Source ${timepoint.sourceId} already exists: $e");
      }

      // 2. Tạo Layer (RasterLayer) để vẽ Radar lên map
      // Nó sẽ tham chiếu tới Source vừa tạo
      final rasterLayer = RasterLayer(
        id: timepoint.layerId,
        sourceId: timepoint.sourceId,
      );

      // Khởi tạo radar với độ mờ (opacity) là 0 để ẩn đi
      await mapboxMap.style.addLayerAt(
        rasterLayer,
        LayerPosition(below: darkLayerAboveId),
      );
      await mapboxMap.style.setStyleLayerProperty(
        timepoint.layerId,
        'raster-opacity',
        0.0,
      );
    }
  }

  // Bắt đầu hoặc dừng hiệu ứng Radar (Hòa hoạt)
  Future<void> startAnimation() async {
    if (_isPlaying) return;
    _isPlaying = true;
    _currentIndex = 0;
    _loopRadar();
  }

  Future<void> stopAnimation() async {
    _isPlaying = false;
    // Đặt độ mờ của tất cả các layer về 0 khi dừng
    for (var timepoint in timeline) {
      await mapboxMap.style.setStyleLayerProperty(
        timepoint.layerId,
        'raster-opacity',
        0.0,
      );
    }
  }

  // Vòng lặp hòa hoạt radar Mapbox
  Future<void> _loopRadar() async {
    while (_isPlaying) {
      if (timeline.isEmpty) return;

      final prevIndex = (_currentIndex - 1 + timeline.length) % timeline.length;
      final currIndex = _currentIndex;

      final prevLayerId = timeline[prevIndex].layerId;
      final currLayerId = timeline[currIndex].layerId;

      // 1. Hiện layer hiện tại lên (radar đậm)
      await mapboxMap.style.setStyleLayerProperty(
        currLayerId,
        'raster-opacity',
        0.85,
      ); // Đậm màu radar
      // 2. Ẩn layer trước đó (hoặc mờ dần - tốn hiệu năng hơn)
      await mapboxMap.style.setStyleLayerProperty(
        prevLayerId,
        'raster-opacity',
        0.0,
      );

      // Thời gian chuyển đổi giữa các mốc
      await Future.delayed(const Duration(milliseconds: 300));

      _currentIndex = (_currentIndex + 1) % timeline.length;
    }
  }
}
