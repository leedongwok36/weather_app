import 'package:flutter/material.dart';
import 'home_screens.dart';
import 'map_screen.dart';
import 'cities_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0; // Tự quản lý trang đang chọn

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const Center(child: Text("Widgets Screen")), 
    const CitiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      extendBody: true,
      body: IndexedStack(
      index: _selectedIndex,
      children: _screens, 
    ),
    bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1B33), 
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.cloud, "THỜI TIẾT"),
          _buildNavItem(1, Icons.map_outlined, "BẢN ĐỒ"),
          _buildNavItem(2, Icons.grid_view_rounded, "TIỆN ÍCH"),
          _buildNavItem(3, Icons.location_on_outlined, "THÀNH PHỐ"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 0.5),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
