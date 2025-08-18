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
    with TickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final AnimationController _slideController;
  late int _currentIndex;

  bool _isPlaying = false;
  bool _isFavorite = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  bool _isLoading = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _currentIndex = _findCurrentSongIndex();
    _audioPlayer = AudioPlayer();
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _initializePlayer();
    _slideController.forward();
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
    setState(() => _isLoading = true);
    try {
      await _audioPlayer.setUrl(url);
      setState(() {
        _duration = _audioPlayer.duration ?? Duration.zero;
        _position = Duration.zero;
        _isLoading = false;
      });
      await _audioPlayer.play();
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading audio: $e');
      _showErrorSnackBar();
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading audio'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onPlayerStateChanged(PlayerState state) {
    if (!mounted) return;

    setState(() {
      _isPlaying = state.playing;
    });
    
    if (state.playing) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
    } else {
      _rotationController.stop();
      _pulseController.stop();
    }
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
    
    // Restart slide animation for song change
    _slideController.reset();
    _slideController.forward();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.allSongs[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade200.withOpacity(0.3),
              AppColors.background,
              Colors.blue.shade100.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildEnhancedAlbumArt(song['image']),
                        const SizedBox(height: 40),
                        _buildEnhancedSongInfo(song),
                        const SizedBox(height: 50),
                        _buildEnhancedProgressSection(),
                        const SizedBox(height: 50),
                        _buildEnhancedPlaybackControls(),
                        const SizedBox(height: 30),
                        _buildEnhancedShuffleRepeatControls(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack,
      )),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                iconSize: 28,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Text(
              'Now Playing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red.shade400 : Colors.black87,
                  ),
                  iconSize: 24,
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    if (_isFavorite) {
                      _pulseController.forward().then((_) => _pulseController.reverse());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedAlbumArt(String imageUrl) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              height: 320 + (_pulseController.value * 20),
              width: 320 + (_pulseController.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.3 * _pulseController.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main album art
          AnimatedBuilder(
            animation: _rotationController,
            builder: (_, __) => Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Container(
                height: 280,
                width: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.grey.shade100,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(imageUrl.trim()),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.1,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Loading indicator
          if (_isLoading)
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSongInfo(Map<String, dynamic> song) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              song['title'],
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            song['text'],
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber.shade600, size: 18),
                const SizedBox(width: 6),
                Text(
                  song['rating'].toString(),
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProgressSection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.loveColor,
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: AppColors.loveColor,
                overlayColor: AppColors.loveColor.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                trackHeight: 6,
              ),
              child: Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                onChanged: (value) => _audioPlayer.seek(Duration(seconds: value.toInt())),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPlaybackControls() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.skip_previous,
            size: 45,
            onPressed: _playPrevious,
          ),
          _buildMainPlayButton(),
          _buildControlButton(
            icon: Icons.skip_next,
            size: 45,
            onPressed: _playNext,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: size, color: Colors.black87),
        onPressed: onPressed,
        padding: const EdgeInsets.all(15),
      ),
    );
  }

  Widget _buildMainPlayButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => Transform.scale(
        scale: 1.0 + (_pulseController.value * 0.05),
        child: Container(
          height: 85,
          width: 85,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.loveColor,
                AppColors.loveColor.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.loveColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 45,
              color: Colors.white,
            ),
            onPressed: () => _isPlaying ? _audioPlayer.pause() : _audioPlayer.play(),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedShuffleRepeatControls() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(0.8, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleButton(
            icon: Icons.shuffle,
            isActive: _isShuffle,
            onPressed: () => setState(() => _isShuffle = !_isShuffle),
            tooltip: 'Shuffle',
          ),
          const SizedBox(width: 60),
          _buildToggleButton(
            icon: Icons.repeat,
            isActive: _isRepeat,
            onPressed: () => setState(() => _isRepeat = !_isRepeat),
            tooltip: 'Repeat',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? AppColors.loveColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? AppColors.loveColor : Colors.grey.shade500,
          size: 28,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}