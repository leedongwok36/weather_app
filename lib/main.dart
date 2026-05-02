import 'package:flutter/material.dart';
//import 'screens/home_screens.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'screens/navigation_helper.dart';
//import 'screens/map_screen.dart';
//import 'screens/cities_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(
    "pk.eyJ1IjoibGVxdXlkb24iLCJhIjoiY21vaDZsMXE1MDBjdjJyc2YxYm04Mm43OSJ9.sKcB-1zueCcn6v6gpK9STw",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'SanFrancisco', // Có thể đổi font chữ của bạn ở đây
        scaffoldBackgroundColor: const Color(
          0xFF2E335A,
        ), // Màu nền xanh tím trầm
      ),
      home: const MainWrapper(),
    );
  }
}
