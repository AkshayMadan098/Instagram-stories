import '../../domain/repositories/instagram_share_repository.dart';
import '../../../../core/platform/instagram_story_channel.dart';

class InstagramShareRepositoryImpl implements InstagramShareRepository {
  @override
  Future<bool> isInstagramInstalled() async {
    return await InstagramStoryChannel.isInstagramInstalled();
  }

  @override
  Future<InstagramShareResult> shareToStory({
    required String imagePath,
    String? caption,
  }) async {
    return await InstagramStoryChannel.shareToInstagramStory(
      imagePath: imagePath,
      caption: caption,
    );
  }
}
