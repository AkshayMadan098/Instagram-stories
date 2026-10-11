import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../../../core/errors/exceptions.dart';

class CameraRepositoryImpl implements CameraRepository {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      debugPrint('Error getting available cameras: $e');
      return [];
    }
  }

  @override
  Future<CameraController> initializeCamera(
    CameraDescription camera, {
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    final controller = CameraController(
      camera,
      resolution,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.jpeg
          : ImageFormatGroup.bgra8888,
    );

    try {
      await controller.initialize();
      return controller;
    } catch (e) {
      throw AppCameraException('Failed to initialize camera: $e');
    }
  }

  @override
  Future<String> takePicture(CameraController controller) async {
    if (!controller.value.isInitialized) {
      throw AppCameraException('Camera is not initialized');
    }
    if (controller.value.isTakingPicture) {
      throw AppCameraException('Camera is busy capturing');
    }

    try {
      final XFile photo = await controller.takePicture();
      return photo.path;
    } catch (e) {
      throw AppCameraException('Failed to capture photo: $e');
    }
  }

  @override
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      return image?.path;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  @override
  Future<String> generateSamplePhoto() async {
    // Generates a mock vertical story canvas photo (1080x1920)
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, 1080, 1920),
    );

    // Gradient background
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2C3E50),
          Color(0xFF4CA1AF),
          Color(0xFFC4E0E5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(0, 0, 1080, 1920));

    canvas.drawRect(const Rect.fromLTWH(0, 0, 1080, 1920), paint);

    // Some decorative shapes / city skyline backdrop
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(540, 700), 280, circlePaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '📸 Captured Story Photo',
        style: TextStyle(
          color: Colors.white,
          fontSize: 54,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((1080 - textPainter.width) / 2, 850),
    );

    final subtextPainter = TextPainter(
      text: const TextSpan(
        text: 'Draw on this photo or add Figma project stickers!',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 32,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subtextPainter.layout();
    subtextPainter.paint(
      canvas,
      Offset((1080 - subtextPainter.width) / 2, 950),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(1080, 1920);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/sample_photo_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return filePath;
  }
}
