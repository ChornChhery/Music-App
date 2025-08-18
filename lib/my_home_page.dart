import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'song_detail_screen.dart';
import 'app_colors.dart' as AppColors;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
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

  List<dynamic> _getNewSongs() {
    return popularSongs.reversed.take(5).toList();
  }

  List<dynamic> _getPopularSongs() {
    return popularSongs.where((song) => song['rating'] >= 4.6).toList();
  }

  List<dynamic> _getTrendingSongs() {
    final trending = List.from(popularSongs);
    trending.shuffle();
    return trending.take(7).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: AppColors.menu1Color),
                  child: Text(
                    'Chhery Chorn',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: const Icon(Icons.menu, size: 24, color: Colors.black),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: SongSearchDelegate(allSongs: popularSongs),
                            );
                          },
                          child: const Icon(Icons.search),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.notifications),
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

              // Carousel
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

              // TabBar & Tab Views
              Expanded(
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, _) => [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: AppColors.sliverBackground,
                      leading: Container(),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(50),
                        child: Transform.translate(
                          offset: const Offset(10, 0),
                          child: TabBar(
                            controller: _tabController,
                            labelPadding: const EdgeInsets.only(right: 10, bottom: 25),
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
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSongList(_getNewSongs()),
                      _buildSongList(_getPopularSongs()),
                      _buildSongList(_getTrendingSongs()),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSongList(List<dynamic> songs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(song['image']),
            backgroundColor: Colors.grey[300],
          ),
          title: Text(
            song['title'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            song['text'],
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Icon(
            Icons.play_circle_fill,
            color: AppColors.loveColor,
            size: 30,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongDetailScreen(
                  song: song,
                  allSongs: popularSongs.cast<Map<String, dynamic>>(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ✅ Search Delegate
class SongSearchDelegate extends SearchDelegate {
  final List<dynamic> allSongs;

  SongSearchDelegate({required this.allSongs});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allSongs.where((song) {
      final title = song['title'].toString().toLowerCase();
      final text = song['text'].toString().toLowerCase();
      return title.contains(query.toLowerCase()) ||
          text.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(song['image'])),
          title: Text(song['title']),
          subtitle: Text(song['text']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongDetailScreen(
                  song: song,
                  allSongs: allSongs.cast<Map<String, dynamic>>(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allSongs.where((song) {
      final title = song['title'].toString().toLowerCase();
      final text = song['text'].toString().toLowerCase();
      return title.contains(query.toLowerCase()) ||
          text.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final song = suggestions[index];
        return ListTile(
          title: Text(song['title']),
          onTap: () {
            query = song['title'];
            showResults(context);
          },
        );
      },
    );
  }
}
