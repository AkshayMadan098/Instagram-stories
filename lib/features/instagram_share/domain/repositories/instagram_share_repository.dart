import '../../../../core/platform/instagram_story_channel.dart';

abstract class InstagramShareRepository {
  Future<bool> isInstagramInstalled();
  Future<InstagramShareResult> shareToStory({
    required String imagePath,
    String? caption,
  });
}
