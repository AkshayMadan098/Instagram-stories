import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_state.dart';
import '../../domain/repositories/camera_repository.dart';

class CameraCubit extends Cubit<CameraState> {
  final CameraRepository repository;

  CameraCubit({required this.repository}) : super(const CameraState());

  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: CameraStatus.loading));

      // Request camera permission
      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted && !kIsWeb) {
        debugPrint('Camera permission not granted: $permissionStatus');
      }

      final cameras = await repository.getAvailableCameras();

      if (cameras.isEmpty) {
        emit(state.copyWith(
          status: CameraStatus.ready,
          availableCameras: [],
        ));
        return;
      }

      final controller = await repository.initializeCamera(cameras.first);

      emit(state.copyWith(
        status: CameraStatus.ready,
        controller: controller,
        availableCameras: cameras,
        currentCameraIndex: 0,
      ));
    } catch (e) {
      debugPrint('Error initializing camera cubit: $e');
      emit(state.copyWith(
        status: CameraStatus.ready,
        errorMessage: 'Camera not available on this device: $e',
      ));
    }
  }

  Future<void> flipCamera() async {
    if (state.availableCameras.length < 2) return;

    final nextIndex =
        (state.currentCameraIndex + 1) % state.availableCameras.length;
    final nextCamera = state.availableCameras[nextIndex];

    try {
      emit(state.copyWith(status: CameraStatus.loading));
      await state.controller?.dispose();

      final newController = await repository.initializeCamera(nextCamera);

      emit(state.copyWith(
        status: CameraStatus.ready,
        controller: newController,
        currentCameraIndex: nextIndex,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Failed to switch camera: $e',
      ));
    }
  }

  Future<void> toggleFlash() async {
    if (state.controller == null || !state.isInitialized) return;

    FlashMode nextMode;
    switch (state.flashMode) {
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.off;
        break;
      case FlashMode.off:
      default:
        nextMode = FlashMode.auto;
        break;
    }

    try {
      await state.controller!.setFlashMode(nextMode);
      emit(state.copyWith(flashMode: nextMode));
    } catch (e) {
      debugPrint('Flash mode not supported on this device: $e');
    }
  }

  Future<void> takePicture() async {
    if (state.controller == null || !state.isInitialized) {
      // If camera hardware is not available (e.g. desktop simulator), generate sample photo
      await useSamplePhoto();
      return;
    }

    try {
      emit(state.copyWith(status: CameraStatus.capturing));
      final imagePath = await repository.takePicture(state.controller!);

      emit(state.copyWith(
        status: CameraStatus.captured,
        capturedImagePath: imagePath,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Failed to take photo: $e',
      ));
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final imagePath = await repository.pickImageFromGallery();
      if (imagePath != null) {
        emit(state.copyWith(
          status: CameraStatus.captured,
          capturedImagePath: imagePath,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Failed to pick image: $e',
      ));
    }
  }

  Future<void> useSamplePhoto() async {
    try {
      emit(state.copyWith(status: CameraStatus.capturing));
      final samplePath = await repository.generateSamplePhoto();
      emit(state.copyWith(
        status: CameraStatus.captured,
        capturedImagePath: samplePath,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Failed to generate sample photo: $e',
      ));
    }
  }

  void resetCapture() {
    emit(state.copyWith(
      status: CameraStatus.ready,
      capturedImagePath: null,
    ));
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }
}
