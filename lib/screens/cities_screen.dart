import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../logic/shared_nav_bar.dart';

class CitiesScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? savedCities;
  const CitiesScreen({super.key, this.savedCities});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {

  List<Map<String, dynamic>> _citiesData = [];
  bool _isLoading = true;


  final String _apiKey = "api  key openwweather";


  final List<String> _defaultCities = [
    "Hanoi",
    "Ho Chi Minh City",
    "Da Nang",
    "Can Tho",
  ];

  @override
  void initState() {
    super.initState();
    _loadAllWeather(); 
  }

 
  String _getCityImageUrl(String cityName) {
    if (cityName.contains("Hanoi") || cityName.contains("Hà Nội")) {
      return "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500";
    }
    if (cityName.contains("Ho Chi Minh") || cityName.contains("Hồ Chí Minh")) {
      return "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=500";
    }
    if (cityName.contains("Da Nang") || cityName.contains("Đà Nẵng")) {
      return "https://cdn11.dienmaycholon.vn/filewebdmclnew/DMCL21/Picture/News/News_expe_12587/12587.png?version=282315"; // Cầu Rồng (Link mới)
    }
    if (cityName.contains("Can Tho") || cityName.contains("Cần Thơ")) {
      return "https://r2.nucuoimekong.com/wp-content/uploads/cau-can-tho-du-lich-can-tho-nu-cuoi-me-kong.webp"; // Miền tây
    }
  
    return "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=600";
  }

  
  Color _getCityColor(String cityName) {
    if (cityName.contains("Hanoi") || cityName.contains("Hà Nội")) {
      return const Color(0xFF6366F1); 
    }
    if (cityName.contains("Ho Chi Minh") || cityName.contains("Hồ Chí Minh")) {
      return const Color(0xFFF97316); 
    }
    if (cityName.contains("Da Nang") || cityName.contains("Đà Nẵng")) {
      return const Color(0xFF14B8A6); 
    }
    return const Color(0xFF22C55E); 
  }

  void _loadAllWeather() async {
    List<Map<String, dynamic>> results = [];
    for (String name in _defaultCities) {
      try {
        final url =
            'https://api.openweathermap.org/data/2.5/weather?q=$name,VN&units=metric&appid=$_apiKey&lang=vi';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          results.add(jsonDecode(response.body));
        }
      } catch (e) {
        debugPrint("Lỗi tải $name: $e");
      }
    }
    if (mounted) {
      setState(() {
        _citiesData = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Nền đen sâu chuẩn hình
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.search, color: Colors.white),
        title: const Text(
          "Cities",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          const Icon(Icons.more_vert, color: Colors.white),
          const SizedBox(width: 15),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Thanh tìm kiếm (Giống hình mẫu)
                _buildSearchBar(),

                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _citiesData.length,
                    itemBuilder: (context, index) {
                      return _buildCityCard(_citiesData[index]);
                    },
                  ),
                ),

              
                _buildManageButton(),
                
              ],
            ),
            bottomNavigationBar: const SharedNavBar(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      // Thanh footer đồng bộ
    );
  }

  Widget _buildCityCard(Map<String, dynamic> data) {
    final name = data['name'] ?? "Unknown";
    final temp = (data['main']['temp'] as num).round();
    final high = (data['main']['temp_max'] as num).round();
    final low = (data['main']['temp_min'] as num).round();
    final desc = data['weather'][0]['description'];

    final color = _getCityColor(name);
    final imageUrl = _getCityImageUrl(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
         
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Opacity(
              opacity: 0.3, // Để ảnh chìm xuống, làm nổi bật chữ
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

       
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
               
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow
                            .ellipsis, 
                      ),
                      const SizedBox(height: 5),
                      Text(
                        desc.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

             
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$temp°",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "H:$high°  L:$low°",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.white38),
            SizedBox(width: 10),
            Text(
              "Search for a city or airport",
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        "Manage Saved Locations",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
