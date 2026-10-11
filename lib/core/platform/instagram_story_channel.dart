import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

enum InstagramShareResult {
  success,
  notInstalled,
  error,
  simulated,
}

class InstagramStoryChannel {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.shareMethodChannel);

  /// Checks if Instagram app is installed on the device.
  static Future<bool> isInstagramInstalled() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      // On desktop or web, Instagram mobile app is not installed
      return false;
    }

    try {
      final bool? isInstalled =
          await _channel.invokeMethod<bool>('isInstagramInstalled');
      return isInstalled ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking Instagram installation: ${e.message}');
      return false;
    }
  }

  /// Directly launches Instagram Stories composer with the provided [imagePath].
  /// [caption] is also saved and copied to clipboard for seamless pasting with IG native stickers.
  static Future<InstagramShareResult> shareToInstagramStory({
    required String imagePath,
    String? caption,
    String topColor = '#833AB4',
    String bottomColor = '#FCAF45',
  }) async {
    // If caption is present, automatically copy it to clipboard
    if (caption != null && caption.trim().isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: caption.trim()));
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      // Desktop / Web / Simulator simulated mode
      debugPrint('[Dev/Simulator] Simulated Instagram Story share with image: $imagePath');
      return InstagramShareResult.simulated;
    }

    try {
      final String? result =
          await _channel.invokeMethod<String>('shareToInstagramStory', {
        'imagePath': imagePath,
        'caption': caption,
        'topColor': topColor,
        'bottomColor': bottomColor,
      });

      if (result == 'success') {
        return InstagramShareResult.success;
      } else if (result == 'instagram_not_installed') {
        return InstagramShareResult.notInstalled;
      } else {
        return InstagramShareResult.error;
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException sharing to Instagram Story: ${e.message}');
      return InstagramShareResult.error;
    } catch (e) {
      debugPrint('Exception sharing to Instagram Story: $e');
      return InstagramShareResult.error;
    }
  }
}
