import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class ImageSaver {
  /// Captures the widget referenced by [boundaryKey] and saves it as a PNG file.
  /// Returns the absolute path to the saved file.
  static Future<String> captureWidgetToImage(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('RenderRepaintBoundary is null or not found');
      }

      // Capture image with high quality pixel ratio
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to PNG byte data');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${tempDir.path}/story_$timestamp.png';

      final File file = File(filePath);
      await file.writeAsBytes(pngBytes, flush: true);

      return filePath;
    } catch (e) {
      debugPrint('Error capturing widget to image: $e');
      rethrow;
    }
  }
}
