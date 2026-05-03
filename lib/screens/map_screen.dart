import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class WeatherDisplayData {
  final int temp;
  final int tempMax;
  final int tempMin;
  final int humidity;
  final String cityName;
  final double rain;
  final String windSpeed;

  WeatherDisplayData.fromMap(Map<String, dynamic>? data)
      : temp = (data?['main']?['temp'] ?? 0).toInt(),
        tempMax = (data?['main']?['temp_max'] ?? 0).toInt(),
        tempMin = (data?['main']?['temp_min'] ?? 0).toInt(),
        humidity = data?['main']?['humidity'] ?? 0,
        cityName = data?['name'] ?? 'BẢN ĐỒ',
        rain = (data?['rain']?['1h'] ?? 0.0).toDouble(),
        windSpeed = (data?['wind']?['speed'] ?? 0).toString();
}

class MapScreen extends StatefulWidget {
  final Map<String, dynamic>? weatherData;

  const MapScreen({
    super.key,
    this.weatherData,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapboxMap;

  late final CameraOptions _initialCamera;
  late final Widget _mapWidget;
  late final Stopwatch _watch;

  StreamSubscription<List<ConnectivityResult>>? _networkSubscription;

  bool _styleLoaded = false;
  bool _hasNetwork = true;

  double _lat = 10.8231;
  double _lon = 106.6297;

  WeatherDisplayData? _data;

  @override
  void initState() {
    super.initState();

    _watch = Stopwatch()..start();

    _prepareData();
    _prepareMap();

    _checkNetwork();
    _listenNetwork();
  }

  void _prepareData() {
    if (widget.weatherData != null) {
      _data = WeatherDisplayData.fromMap(widget.weatherData);

      if (widget.weatherData!['coord'] != null) {
        _lat = widget.weatherData!['coord']['lat']?.toDouble() ?? _lat;
        _lon = widget.weatherData!['coord']['lon']?.toDouble() ?? _lon;
      }
    } else {
      _data = WeatherDisplayData.fromMap(null);
    }
  }

  void _prepareMap() {
    _initialCamera = CameraOptions(
      center: Point(coordinates: Position(_lon, _lat)),
      zoom: 9.0,
    );

    _mapWidget = MapWidget(
      key: const ValueKey('weather-map'),
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: _initialCamera,
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: (_) async {
        debugPrint(
          'STYLE LOADED after ${_watch.elapsedMilliseconds} ms',
        );

        if (!mounted) return;

        setState(() {
          _styleLoaded = true;
        });

        await Future.delayed(
          const Duration(milliseconds: 250),
        );

        await _mapboxMap?.location.updateSettings(
          LocationComponentSettings(
            enabled: true,
            pulsingEnabled: false,
          ),
        );

        await _addMarker();
      },
    );
  }

  Future<void> _checkNetwork() async {
    final result = await Connectivity().checkConnectivity();

    if (!mounted) return;

    setState(() {
      _hasNetwork = !result.contains(ConnectivityResult.none);
    });
  }

  void _listenNetwork() {
    _networkSubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (!mounted) return;

      setState(() {
        _hasNetwork = !result.contains(ConnectivityResult.none);
      });
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;

    debugPrint(
      'MAP CREATED after ${_watch.elapsedMilliseconds} ms',
    );
  }

  Future<void> _addMarker() async {
    if (_mapboxMap == null) return;

    final manager =
        await _mapboxMap!.annotations.createPointAnnotationManager();

    await manager.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(_lon, _lat),
        ),
      ),
    );
  }

  Future<void> _zoom(bool zoomIn) async {
    if (_mapboxMap == null) return;

    final state = await _mapboxMap!.getCameraState();

    _mapboxMap!.setCamera(
      CameraOptions(
        zoom: zoomIn ? state.zoom + 1 : state.zoom - 1,
      ),
    );
  }

  void _goHome() {
    _mapboxMap?.flyTo(
      _initialCamera,
      MapAnimationOptions(duration: 800),
    );
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _mapWidget),

          if (!_styleLoaded && _hasNetwork)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          if (!_hasNetwork)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: const Center(
                  child: Text(
                    'Không có kết nối mạng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            top: 55,
            left: 18,
            right: 18,
            child: _buildTopCard(data),
          ),

          Positioned(
            right: 16,
            bottom: 36,
            child: Column(
              children: [
                _buildControl(Icons.add, () => _zoom(true)),
                const SizedBox(height: 10),
                _buildControl(Icons.remove, () => _zoom(false)),
                const SizedBox(height: 10),
                _buildControl(Icons.my_location, _goHome),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard(WeatherDisplayData data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.42),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.temp}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'C: ${data.tempMax}°   T: ${data.tempMin}°',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMiniStat(
                Icons.water_drop,
                '${data.humidity}%',
              ),
              const SizedBox(width: 18),
              _buildMiniStat(
                Icons.air,
                '${data.windSpeed} m/s',
              ),
              const SizedBox(width: 18),
              _buildMiniStat(
                Icons.umbrella,
                '${data.rain} mm',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildControl(
    IconData icon,
    VoidCallback onTap,
  ) {
    return FloatingActionButton.small(
      heroTag: icon.codePoint.toString(),
      onPressed: onTap,
      backgroundColor: Colors.black87,
      child: Icon(icon),
    );
  }
}