import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'app_colors.dart' as AppColors;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late List<dynamic> popularSongs;
  late ScrollController _scrollController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    popularSongs = [];
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final String jsonString = await rootBundle.loadString('json/popularSongs.json');
      final List<dynamic> data = json.decode(jsonString);

      // Trim whitespace from URLs
      data.forEach((song) {
        song['image'] = (song['image'] as String).trim();
        song['audio'] = (song['audio'] as String).trim();
      });

      setState(() {
        popularSongs = data;
      });
    } catch (e) {
      print("Failed to load songs: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, size: 24, color: Colors.black),
                    Row(
                      children: const [
                        Icon(Icons.search),
                        SizedBox(width: 10),
                        Icon(Icons.notifications),
                      ],
                    ),
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Music App",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Image Carousel (PageView)
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: popularSongs.length,
                  itemBuilder: (context, index) {
                    final song = popularSongs[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(song['image']),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // TabBar with NestedScrollView
              Expanded(
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: AppColors.sliverBackground,
                      bottom: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 7,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        tabs: [
                          _buildTab("New", AppColors.menu1Color),
                          _buildTab("Popular", AppColors.menu2Color),
                          _buildTab("Trending", AppColors.menu3Color),
                        ],
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSongList(),
                      _buildSongList(),
                      _buildSongList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Build a styled tab
  Widget _buildTab(String label, Color color) {
    return Container(
      width: 120,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Helper: Build list of songs
  Widget _buildSongList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: popularSongs.length,
      itemBuilder: (context, index) {
        final song = popularSongs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(song['image']),
            backgroundColor: Colors.grey[300],
          ),
          title: Text(song['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(song['text'], style: TextStyle(color: Colors.grey[600])),
          trailing:  Icon(Icons.play_circle_fill, color:AppColors.loveColor, size: 30),
        );
      },
    );
  }
}