import 'package:flutter/material.dart';
//import 'screens/home_screens.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'screens/navigation_helper.dart';
//import 'screens/map_screen.dart';
//import 'screens/cities_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(
    "dán token của mapbox",
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
        fontFamily: 'SanFrancisco',
        scaffoldBackgroundColor: const Color(
          0xFF2E335A,
        ), 
      ),
      home: const MainWrapper(),
    );
  }
}
