import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadVideo({
    required String userId,
    required Uint8List videoBytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final postId = _uuid.v4();
    final extension = fileName.split('.').last.toLowerCase();
    final storagePath = 'videos/$userId/$postId.$extension';
    
    final ref = _storage.ref().child(storagePath);
    
    final metadata = SettableMetadata(
      contentType: 'video/$extension',
      customMetadata: {
        'userId': userId,
        'postId': postId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
    
    final uploadTask = ref.putData(videoBytes, metadata);
    
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }
    
    await uploadTask;
    
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteVideo(String videoUrl) async {
    try {
      final ref = _storage.refFromURL(videoUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadThumbnail({
    required String userId,
    required String postId,
    required Uint8List thumbnailBytes,
  }) async {
    final storagePath = 'thumbnails/$userId/$postId.jpg';
    
    final ref = _storage.ref().child(storagePath);
    
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );
    
    await ref.putData(thumbnailBytes, metadata);
    
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadStoryMedia({
    required String userId,
    required Uint8List mediaBytes,
    required String fileName,
    required bool isVideo,
    void Function(double progress)? onProgress,
  }) async {
    final storyId = _uuid.v4();
    final extension = fileName.split('.').last.toLowerCase();
    final storagePath = 'stories/$userId/$storyId.$extension';
    
    final ref = _storage.ref().child(storagePath);
    
    final contentType = isVideo ? 'video/$extension' : 'image/$extension';
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {
        'userId': userId,
        'storyId': storyId,
        'uploadedAt': DateTime.now().toIso8601String(),
        'mediaType': isVideo ? 'video' : 'image',
      },
    );
    
    final uploadTask = ref.putData(mediaBytes, metadata);
    
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }
    
    await uploadTask;
    
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteStoryMedia(String mediaUrl) async {
    try {
      final ref = _storage.refFromURL(mediaUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }
}
