import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../services/story_service.dart';
import 'story_viewer.dart';

class StoriesBar extends StatelessWidget {
  final VoidCallback? onAddStory;

  const StoriesBar({
    super.key,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    final storyService = StoryService();

    return Container(
      height: 110,
      color: Colors.black,
      child: StreamBuilder<List<UserStories>>(
        stream: storyService.getActiveStoriesByUserStream(),
        builder: (context, snapshot) {
          final userStoriesList = snapshot.data ?? [];

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: userStoriesList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _AddStoryButton(onTap: onAddStory);
              }

              final userStories = userStoriesList[index - 1];
              return _StoryAvatar(
                userStories: userStories,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StoryViewer(
                        userStories: userStories,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddStoryButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[900],
                border: Border.all(color: Colors.grey[700]!, width: 2),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add Story',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final UserStories userStories;
  final VoidCallback onTap;

  const _StoryAvatar({
    required this.userStories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 65,
              height: 65,
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
            const SizedBox(height: 6),
            Text(
              userStories.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        size: 32,
      ),
    );
  }
}
