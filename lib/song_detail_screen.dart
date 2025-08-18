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
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  late final AnimationController _animationController;
  late int _currentIndex;

  bool _isPlaying = false;
  bool _isFavorite = false;
  bool _isShuffle = false;
  bool _isRepeat = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _currentIndex = _findCurrentSongIndex();
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _initializePlayer();
  }

  int _findCurrentSongIndex() {
    return widget.allSongs.indexWhere((song) =>
        song['title'] == widget.song['title'] &&
        song['text'] == widget.song['text']);
  }

  void _initializePlayer() {
    _setAudio(widget.allSongs[_currentIndex]['audio']);

    _audioPlayer.playerStateStream.listen(_onPlayerStateChanged);
    _audioPlayer.positionStream.listen(_onPositionChanged);
    _audioPlayer.processingStateStream.listen(_onProcessingStateChanged);
  }

  Future<void> _setAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      setState(() {
        _duration = _audioPlayer.duration ?? Duration.zero;
        _position = Duration.zero;
      });
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  void _onPlayerStateChanged(PlayerState state) {
    if (!mounted) return;

    setState(() {
      _isPlaying = state.playing;
      state.playing
          ? _animationController.repeat()
          : _animationController.stop();
    });
  }

  void _onPositionChanged(Duration position) {
    if (!mounted) return;
    setState(() => _position = position);
  }

  void _onProcessingStateChanged(ProcessingState state) {
    if (state == ProcessingState.completed) {
      if (_isRepeat) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
      } else {
        _playNext();
      }
    }
  }

  void _playPrevious() {
    _changeSong(_isShuffle
        ? _getRandomIndex()
        : (_currentIndex - 1 + widget.allSongs.length) %
            widget.allSongs.length);
  }

  void _playNext() {
    _changeSong(_isShuffle
        ? _getRandomIndex()
        : (_currentIndex + 1) % widget.allSongs.length);
  }

  int _getRandomIndex() => math.Random().nextInt(widget.allSongs.length);

  void _changeSong(int newIndex) {
    setState(() => _currentIndex = newIndex);
    _setAudio(widget.allSongs[_currentIndex]['audio']);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.allSongs[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildRotatingAlbumArt(song['image']),
            const SizedBox(height: 30),
            _buildSongInfo(song),
            const SizedBox(height: 40),
            _buildProgressSlider(),
            _buildTimeLabels(),
            const SizedBox(height: 40),
            _buildPlaybackControls(),
            const SizedBox(height: 20),
            _buildShuffleRepeatControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildRotatingAlbumArt(String imageUrl) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) => Transform.rotate(
        angle: _animationController.value * 2 * math.pi,
        child: Container(
          height: 280,
          width: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(imageUrl.trim()),
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
      ),
    );
  }

  Widget _buildSongInfo(Map<String, dynamic> song) {
    return Column(
      children: [
        Text(
          song['title'],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          song['text'],
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(song['rating'].toString(), style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.loveColor,
        inactiveTrackColor: Colors.grey[300],
        thumbColor: AppColors.loveColor,
        overlayColor: AppColors.loveColor.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      child: Slider(
        min: 0,
        max: _duration.inSeconds.toDouble(),
        value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
        onChanged: (value) => _audioPlayer.seek(Duration(seconds: value.toInt())),
      ),
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_formatDuration(_position)),
          Text(_formatDuration(_duration)),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(icon: const Icon(Icons.skip_previous, size: 40), onPressed: _playPrevious),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            size: 60,
            color: AppColors.loveColor,
          ),
          onPressed: () => _isPlaying ? _audioPlayer.pause() : _audioPlayer.play(),
        ),
        IconButton(icon: const Icon(Icons.skip_next, size: 40), onPressed: _playNext),
      ],
    );
  }

  Widget _buildShuffleRepeatControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.shuffle, color: _isShuffle ? AppColors.loveColor : Colors.grey),
          onPressed: () => setState(() => _isShuffle = !_isShuffle),
          tooltip: 'Shuffle',
        ),
        const SizedBox(width: 40),
        IconButton(
          icon: Icon(Icons.repeat, color: _isRepeat ? AppColors.loveColor : Colors.grey),
          onPressed: () => setState(() => _isRepeat = !_isRepeat),
          tooltip: 'Repeat',
        ),
      ],
    );
  }
}
