import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/instagram_share_cubit.dart';
import '../cubit/instagram_share_state.dart';

class InstagramShareModal extends StatelessWidget {
  final String imagePath;
  final String? caption;

  const InstagramShareModal({
    super.key,
    required this.imagePath,
    this.caption,
  });

  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    String? caption,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => InstagramShareModal(
        imagePath: imagePath,
        caption: caption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: BlocConsumer<InstagramShareCubit, InstagramShareState>(
          listener: (context, state) {
            if (state is InstagramShareSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF333333),
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.instagramPink),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.captionCopied
                              ? 'Story loaded & caption copied to clipboard!'
                              : 'Story launched in Instagram!',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is InstagramShareLoading) {
              return _buildLoading(context, state.statusMessage);
            } else if (state is InstagramShareSuccess) {
              return _buildSuccess(context, state);
            } else if (state is InstagramShareSimulated) {
              return _buildSimulated(context, state);
            } else if (state is InstagramShareNotInstalled) {
              return _buildNotInstalled(context, state);
            } else if (state is InstagramShareFailure) {
              return _buildFailure(context, state.message);
            } else {
              return _buildInitial(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        const SizedBox(height: 12),
        _buildInstagramLogoHeader(),
        const SizedBox(height: 20),
        const Text(
          'Share Directly to Instagram Stories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          caption != null && caption!.isNotEmpty
              ? 'Your photo will open directly in Instagram Stories and the caption will be automatically copied to your clipboard.'
              : 'Your photo and canvas artwork will open directly in the Instagram Story camera editor.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildGradientButton(
          label: 'Open Instagram Stories',
          onTap: () {
            context.read<InstagramShareCubit>().shareToInstagramStory(
                  imagePath: imagePath,
                  caption: caption,
                );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildLoading(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        const SizedBox(height: 24),
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.instagramStoryRing,
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1E1E1E),
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.instagramPink,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Transitioning to Instagram Stories...',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context, InstagramShareSuccess state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        const SizedBox(height: 16),
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00C853),
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 14),
        const Text(
          'Instagram Stories Launched!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (state.captionCopied)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.content_paste, color: AppColors.instagramPink, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Caption copied: "${state.caption ?? ''}"',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF333333),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Back to Editor'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSimulated(BuildContext context, InstagramShareSimulated state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        const SizedBox(height: 14),
        _buildInstagramLogoHeader(),
        const SizedBox(height: 14),
        const Text(
          'Development / Simulator Mode',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Instagram Stories Intent was triggered successfully! On a real Android or iOS device with Instagram installed, this opens the Instagram Stories composer directly.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        if (state.caption != null && state.caption!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Caption in clipboard: "${state.caption}"',
              style: const TextStyle(color: Colors.amber, fontSize: 12),
            ),
          ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
              ),
              child: const Text('Close'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                context.read<InstagramShareCubit>().shareViaSystemFallback(
                      imagePath: imagePath,
                      caption: caption,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.instagramPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test System Share'),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildNotInstalled(BuildContext context, InstagramShareNotInstalled state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        const SizedBox(height: 14),
        const Icon(Icons.info_outline, color: Colors.amber, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Instagram Not Installed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Instagram is not found on this device. You can share your story using any other app on your phone.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildGradientButton(
          label: 'Share to Other Apps',
          onTap: () {
            context.read<InstagramShareCubit>().shareViaSystemFallback(
                  imagePath: imagePath,
                  caption: caption,
                );
          },
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
      ],
    );
  }

  Widget _buildFailure(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        const SizedBox(height: 14),
        const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Share Failed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                context.read<InstagramShareCubit>().shareToInstagramStory(
                      imagePath: imagePath,
                      caption: caption,
                    );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.instagramPink),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildInstagramLogoHeader() {
    return Container(
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.instagramStoryRing,
      ),
      child: const Center(
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.instagramGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66E1306C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
