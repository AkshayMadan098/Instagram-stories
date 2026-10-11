import 'package:camera/camera.dart';

abstract class CameraRepository {
  Future<List<CameraDescription>> getAvailableCameras();
  Future<CameraController> initializeCamera(
    CameraDescription camera, {
    ResolutionPreset resolution = ResolutionPreset.max,
  });
  Future<String> takePicture(CameraController controller);
  Future<String?> pickImageFromGallery();
  Future<String> generateSamplePhoto();
}
