import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart';
import '../widgets/camera_shutter_button.dart';
import '../../../canvas/presentation/pages/photo_canvas_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<CameraCubit>().initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final cameraCubit = context.read<CameraCubit>();
    if (cameraCubit.state.controller == null ||
        !cameraCubit.state.controller!.value.isInitialized) {
      return;
    }

    if (lifecycleState == AppLifecycleState.inactive) {
      cameraCubit.state.controller?.dispose();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      cameraCubit.initialize();
    }
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
      default:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CameraCubit, CameraState>(
        listener: (context, state) {
          if (state.status == CameraStatus.captured &&
              state.capturedImagePath != null) {
            final cameraCubit = context.read<CameraCubit>();
            Navigator.of(context)
                .push(
              PhotoCanvasPage.route(imagePath: state.capturedImagePath!),
            )
                .then((_) {
              cameraCubit.resetCapture();
            });
          } else if (state.status == CameraStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.danger,
                content: Text(state.errorMessage!),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. CAMERA VIEW OR FALLBACK PREVIEW
              _buildCameraView(context, state),

              // 2. TOP ACTION BAR
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(context, state),
              ),

              // 3. BOTTOM CAMERA CONTROLS
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraView(BuildContext context, CameraState state) {
    if (state.status == CameraStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.instagramPink),
      );
    }

    if (state.controller != null && state.isInitialized) {
      // Physical camera preview
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CameraPreview(state.controller!),
      );
    }

    // Fallback UI (desktop simulator / emulator or camera not attached)
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.instagramStoryRing,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Camera Viewfinder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the capture button to take a photo or select an image from your gallery to edit on the canvas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.read<CameraCubit>().useSamplePhoto(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.instagramPink,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Capture Sample Photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CameraState state) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black87, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flash toggle button
          IconButton(
            icon: Icon(
              _getFlashIcon(state.flashMode),
              color: Colors.white,
              size: 26,
            ),
            tooltip: 'Flash Mode',
            onPressed: () => context.read<CameraCubit>().toggleFlash(),
          ),

          // Story Brand Title
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.instagramGradient,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'STORY CAMERA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          // Settings / Sample trigger
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
            tooltip: 'Sample Photo',
            onPressed: () => context.read<CameraCubit>().useSamplePhoto(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, CameraState state) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
        top: 24,
        left: 36,
        right: 36,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black87, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gallery photo picker button
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
            tooltip: 'Choose from Gallery',
            onPressed: () => context.read<CameraCubit>().pickFromGallery(),
          ),

          // Shutter Button
          CameraShutterButton(
            isCapturing: state.status == CameraStatus.capturing,
            onTap: () => context.read<CameraCubit>().takePicture(),
          ),

          // Flip camera button
          IconButton(
            icon: Icon(
              Icons.flip_camera_ios,
              color: state.availableCameras.length > 1
                  ? Colors.white
                  : Colors.white38,
              size: 30,
            ),
            tooltip: 'Flip Camera',
            onPressed: state.availableCameras.length > 1
                ? () => context.read<CameraCubit>().flipCamera()
                : null,
          ),
        ],
      ),
    );
  }
}
