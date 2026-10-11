class AppCameraException implements Exception {
  final String message;
  AppCameraException(this.message);

  @override
  String toString() => 'AppCameraException: $message';
}

class ShareException implements Exception {
  final String message;
  ShareException(this.message);

  @override
  String toString() => 'ShareException: $message';
}
