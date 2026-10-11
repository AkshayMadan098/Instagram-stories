import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

enum CameraStatus {
  initial,
  loading,
  ready,
  capturing,
  captured,
  error,
}

class CameraState extends Equatable {
  final CameraStatus status;
  final CameraController? controller;
  final List<CameraDescription> availableCameras;
  final int currentCameraIndex;
  final FlashMode flashMode;
  final String? capturedImagePath;
  final String? errorMessage;

  const CameraState({
    this.status = CameraStatus.initial,
    this.controller,
    this.availableCameras = const [],
    this.currentCameraIndex = 0,
    this.flashMode = FlashMode.auto,
    this.capturedImagePath,
    this.errorMessage,
  });

  bool get isFrontCamera {
    if (availableCameras.isEmpty ||
        currentCameraIndex >= availableCameras.length) {
      return false;
    }
    return availableCameras[currentCameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  bool get isInitialized =>
      controller != null && controller!.value.isInitialized;

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    List<CameraDescription>? availableCameras,
    int? currentCameraIndex,
    FlashMode? flashMode,
    String? capturedImagePath,
    String? errorMessage,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      availableCameras: availableCameras ?? this.availableCameras,
      currentCameraIndex: currentCameraIndex ?? this.currentCameraIndex,
      flashMode: flashMode ?? this.flashMode,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        controller,
        availableCameras,
        currentCameraIndex,
        flashMode,
        capturedImagePath,
        errorMessage,
      ];
}
