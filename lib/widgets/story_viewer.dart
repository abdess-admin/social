import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/story_model.dart';
import '../services/story_service.dart';

class StoryViewer extends StatefulWidget {
  final UserStories userStories;
  final int initialIndex;

  const StoryViewer({
    super.key,
    required this.userStories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  final StoryService _storyService = StoryService();
  
  late int _currentIndex;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  final Set<String> _viewedStoryIds = {};

  static const Duration _imageDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    _progressController = AnimationController(
      vsync: this,
      duration: _imageDuration,
    );
    
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNextStory();
      }
    });
    
    _loadCurrentStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  StoryModel get _currentStory => widget.userStories.stories[_currentIndex];

  void _loadCurrentStory() {
    _progressController.reset();
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;

    _markAsViewed();

    if (_currentStory.isVideo) {
      _initializeVideo();
    } else {
      _progressController.duration = _imageDuration;
      _progressController.forward();
    }
  }

  void _markAsViewed() {
    if (!_viewedStoryIds.contains(_currentStory.id)) {
      _viewedStoryIds.add(_currentStory.id);
      _storyService.incrementViewCount(
        userId: _currentStory.userId,
        storyId: _currentStory.id,
      );
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(_currentStory.mediaUrl),
    );

    try {
      await _videoController!.initialize();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        
        _progressController.duration = _videoController!.value.duration;
        _videoController!.play();
        _progressController.forward();
        
        _videoController!.addListener(_onVideoProgress);
      }
    } catch (e) {
      _goToNextStory();
    }
  }

  void _onVideoProgress() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      final position = _videoController!.value.position;
      final duration = _videoController!.value.duration;
      
      if (duration.inMilliseconds > 0) {
        final progress = position.inMilliseconds / duration.inMilliseconds;
        if (progress >= 0 && progress <= 1) {
          _progressController.value = progress;
        }
      }
      
      if (position >= duration - const Duration(milliseconds: 100)) {
        _goToNextStory();
      }
    }
  }

  void _goToNextStory() {
    if (_currentIndex < widget.userStories.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadCurrentStory();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToPreviousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _loadCurrentStory();
    }
  }

  void _onTapLeft() {
    _goToPreviousStory();
  }

  void _onTapRight() {
    _goToNextStory();
  }

  void _pauseStory() {
    _progressController.stop();
    _videoController?.pause();
  }

  void _resumeStory() {
    if (_currentStory.isVideo && _videoController != null) {
      _videoController!.play();
    }
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => _pauseStory(),
        onLongPressEnd: (_) => _resumeStory(),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story content
            _buildStoryContent(),
            
            // Tap zones for navigation
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _onTapLeft,
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _onTapRight,
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
            
            // Top overlay (progress bars, user info, close button)
            SafeArea(
              child: Column(
                children: [
                  // Progress bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: List.generate(
                        widget.userStories.stories.length,
                        (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                double progress;
                                if (index < _currentIndex) {
                                  progress = 1.0;
                                } else if (index == _currentIndex) {
                                  progress = _progressController.value;
                                } else {
                                  progress = 0.0;
                                }
                                
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    minHeight: 3,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // User info and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: widget.userStories.userAvatarUrl != null
                                ? Image.network(
                                    widget.userStories.userAvatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildDefaultAvatar(),
                                  )
                                : _buildDefaultAvatar(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Username
                        Text(
                          widget.userStories.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Time ago
                        Text(
                          timeago.format(_currentStory.createdAt),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        // Close button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    if (_currentStory.isVideo) {
      if (!_isVideoInitialized) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else {
      return Image.network(
        _currentStory.mediaUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red, size: 48),
          );
        },
      );
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
