import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxRadarTimeline {
  final int time;
  final String tileUrl; 
  final String sourceId;
  final String layerId;

  MapboxRadarTimeline({
    required this.time,
    required this.tileUrl,
    required this.sourceId,
    required this.layerId,
  });

  
}

class MapboxRadarManager {
  final MapboxMap mapboxMap;
  final List<MapboxRadarTimeline> timeline = [];
  int _currentIndex = 0;
  bool _isPlaying = false;


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


  Future<void> initRadarSources() async {
    for (var timepoint in timeline) {
    
      final rasterSource = RasterSource(
        id: timepoint.sourceId,
        tiles: ['https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=434d9d5e3c9d31058b57e29ce7475d25'], // Truyền URL tiles vào đây
        tileSize: 256,
       
      );
   
      try {
        await mapboxMap.style.addSource(rasterSource);
      } catch (e) {
        print("Radar Source ${timepoint.sourceId} already exists: $e");
      }

    
      final rasterLayer = RasterLayer(
        id: timepoint.layerId,
        sourceId: timepoint.sourceId,
      );

     
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


  Future<void> startAnimation() async {
    if (_isPlaying) return;
    _isPlaying = true;
    _currentIndex = 0;
    _loopRadar();
  }

  Future<void> stopAnimation() async {
    _isPlaying = false;
  
    for (var timepoint in timeline) {
      await mapboxMap.style.setStyleLayerProperty(
        timepoint.layerId,
        'raster-opacity',
        0.0,
      );
    }
  }

  
  Future<void> _loopRadar() async {
    while (_isPlaying) {
      if (timeline.isEmpty) return;

      final prevIndex = (_currentIndex - 1 + timeline.length) % timeline.length;
      final currIndex = _currentIndex;

      final prevLayerId = timeline[prevIndex].layerId;
      final currLayerId = timeline[currIndex].layerId;

    
      await mapboxMap.style.setStyleLayerProperty(
        currLayerId,
        'raster-opacity',
        0.85,
      ); 
      await mapboxMap.style.setStyleLayerProperty(
        prevLayerId,
        'raster-opacity',
        0.0,
      );

    
      await Future.delayed(const Duration(milliseconds: 300));

      _currentIndex = (_currentIndex + 1) % timeline.length;
    }
  }
}
