// lib/song_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'app_colors.dart' as AppColors;
import 'dart:math' as math;

class SongDetailScreen extends StatefulWidget {
  final Map<String, dynamic> song;
  final List<Map<String, dynamic>> allSongs;

  const SongDetailScreen({
    Key? key,
    required this.song,
    required this.allSongs,
  }) : super(key: key);

  @override
  _SongDetailScreenState createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _animationController;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _loadAudio();
    _listenToPlayer();
  }

  Future<void> _loadAudio() async {
    try {
      await _audioPlayer.setUrl(widget.song['audio']);
      setState(() {
        _duration = _audioPlayer.duration ?? Duration.zero;
      });
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void _listenToPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.playing) {
            _animationController.repeat();
          } else {
            _animationController.stop();
          }
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  String _formatTime(Duration? duration) {
    if (duration == null) return "00:00";
    int totalSeconds = duration.inSeconds;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Album Art with Rotation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Transform.rotate(
                  angle: _animationController.value * 2 * math.pi,
                  child: Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(song['image'].trim()),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Song Info
            Text(
              song['title'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              song['text'],
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  song['rating'].toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Progress Bar
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.loveColor,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: AppColors.loveColor,
                overlayColor: AppColors.loveColor.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: _position.inSeconds.toDouble(),
                min: 0,
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) async {
                  final duration = Duration(seconds: value.toInt());
                  await _audioPlayer.seek(duration);
                },
              ),
            ),

            // Time Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatTime(_position)),
                  Text(_formatTime(_duration)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40),
                  onPressed: () {
                    // TODO: implement previous
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 60,
                    color: AppColors.loveColor,
                  ),
                  onPressed: () async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      await _audioPlayer.play();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40),
                  onPressed: () {
                    // TODO: implement next
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Shuffle & Repeat
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shuffle, size: 18, color: Colors.grey),
                const SizedBox(width: 20),
                Icon(Icons.repeat, size: 18, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }
}