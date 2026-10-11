class AppConstants {
  static const String appName = 'Story Canvas';
  static const String shareMethodChannel = 'com.example.instagram_stories/share';
  
  // Instagram package & schemes
  static const String instagramAndroidPackage = 'com.instagram.android';
  static const String instagramAndroidStoryAction = 'com.instagram.share.ADD_TO_STORY';
  static const String instagramIosStoryScheme = 'instagram-stories://share';
  
  // Drawing defaults
  static const double defaultStrokeWidth = 5.0;
  static const double minStrokeWidth = 2.0;
  static const double maxStrokeWidth = 24.0;
  
  // Canvas defaults
  static const double stickerInitialScale = 1.0;
  static const double stickerMinScale = 0.4;
  static const double stickerMaxScale = 3.5;
}
