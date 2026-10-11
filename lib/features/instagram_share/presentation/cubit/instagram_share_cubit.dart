import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'instagram_share_state.dart';
import '../../domain/repositories/instagram_share_repository.dart';
import '../../../../core/platform/instagram_story_channel.dart';

class InstagramShareCubit extends Cubit<InstagramShareState> {
  final InstagramShareRepository repository;

  InstagramShareCubit({required this.repository})
      : super(InstagramShareInitial());

  Future<void> shareToInstagramStory({
    required String imagePath,
    String? caption,
  }) async {
    try {
      emit(const InstagramShareLoading(statusMessage: 'Preparing your story...'));

      bool captionCopied = false;
      if (caption != null && caption.trim().isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: caption.trim()));
        captionCopied = true;
      }

      final result = await repository.shareToStory(
        imagePath: imagePath,
        caption: caption,
      );

      switch (result) {
        case InstagramShareResult.success:
          emit(InstagramShareSuccess(
            captionCopied: captionCopied,
            caption: caption,
          ));
          break;
        case InstagramShareResult.notInstalled:
          emit(InstagramShareNotInstalled(
            imagePath: imagePath,
            caption: caption,
          ));
          break;
        case InstagramShareResult.simulated:
          emit(InstagramShareSimulated(
            imagePath: imagePath,
            caption: caption,
          ));
          break;
        case InstagramShareResult.error:
          emit(const InstagramShareFailure(
            'Failed to open Instagram Stories. Please ensure Instagram is installed.',
          ));
          break;
      }
    } catch (e) {
      emit(InstagramShareFailure('Error sharing to Instagram: $e'));
    }
  }

  Future<void> shareViaSystemFallback({
    required String imagePath,
    String? caption,
  }) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath)],
          text: caption,
        ),
      );
    } catch (e) {
      emit(InstagramShareFailure('System share failed: $e'));
    }
  }

  void reset() {
    emit(InstagramShareInitial());
  }
}
