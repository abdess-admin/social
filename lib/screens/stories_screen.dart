import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../providers/auth_provider.dart';
import '../services/story_service.dart';
import '../widgets/story_viewer.dart';
import 'story_upload_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final StoryService _storyService = StoryService();

  void _openStoryUpload() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StoryUploadScreen(),
      ),
    );
  }

  void _openStoryViewer(UserStories userStories) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryViewer(userStories: userStories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Stories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _openStoryUpload,
          ),
        ],
      ),
      body: StreamBuilder<List<UserStories>>(
        stream: _storyService.getActiveStoriesByUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final userStoriesList = snapshot.data ?? [];

          if (userStoriesList.isEmpty) {
            return _buildEmptyState();
          }

          return _buildStoriesList(userStoriesList);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No Stories Yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share a story!\nStories disappear after 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openStoryUpload,
            icon: const Icon(Icons.add),
            label: const Text('Add Story'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesList(List<UserStories> userStoriesList) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userId;

    final myStories = userStoriesList.where((us) => us.userId == currentUserId).toList();
    final otherStories = userStoriesList.where((us) => us.userId != currentUserId).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // My Story section
        _buildSectionHeader('Your Story'),
        const SizedBox(height: 12),
        if (myStories.isNotEmpty)
          _buildStoryTile(myStories.first, isMyStory: true)
        else
          _buildAddStoryTile(),
        
        const SizedBox(height: 24),
        
        // Other Stories section
        if (otherStories.isNotEmpty) ...[
          _buildSectionHeader('Recent Stories'),
          const SizedBox(height: 12),
          ...otherStories.map((userStories) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildStoryTile(userStories),
          )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAddStoryTile() {
    return GestureDetector(
      onTap: _openStoryUpload,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[800],
                border: Border.all(color: Colors.grey[700]!, width: 2),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add to your story',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Share a photo or video',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
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

  Widget _buildStoryTile(UserStories userStories, {bool isMyStory = false}) {
    final storyCount = userStories.stories.length;
    final latestStory = userStories.latestStory;

    return GestureDetector(
      onTap: () => _openStoryViewer(userStories),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar with gradient ring
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: ClipOval(
                  child: userStories.userAvatarUrl != null
                      ? Image.network(
                          userStories.userAvatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMyStory ? 'Your story' : userStories.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$storyCount ${storyCount == 1 ? 'story' : 'stories'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isMyStory)
              IconButton(
                icon: const Icon(Icons.add, color: Colors.purple),
                onPressed: _openStoryUpload,
              ),
            if (latestStory != null)
              Icon(
                latestStory.isVideo ? Icons.videocam : Icons.image,
                color: Colors.grey[600],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
