# Interactive Photo Canvas to Instagram Stories Integration

An end-to-end Flutter feature allowing users to capture photos, draw freely with an Instagram-inspired palette, add stickers from the **Figma Project Status Stickers** library, write styled captions, and share directly to **Instagram Stories** using platform-native intents and URL schemes (without displaying the system share modal).

Built strictly with **Clean Architecture** and **Cubit (`flutter_bloc`)** state management.

> 📦 **Download Pre-built Release APK**:  
> [📲 **Download Android APK (Google Drive)**](https://drive.google.com/file/d/1Zg7asT5z2RM-pxn8qTskf-kiUoFdbh4b/view?usp=sharing)  
> 
> 🎥 **App Demo Video**:  
> [▶️ **Watch Video Walkthrough (Google Drive)**](https://drive.google.com/file/d/1EMHdaVpAtGeMYtqkXuqAlocXXsN-HA1y/view?usp=sharing)

---

## 📸 Key Features

### 1. Camera Interface for Photo Capture
- **Live Viewfinder**: Real-time camera feed powered by the Flutter `camera` package.
- **Camera Controls**:
  - Front/rear camera toggle (flip camera).
  - Flash mode toggle cycling through `Auto`, `Always On`, and `Off`.
  - Instagram-style animated circular shutter button with touch feedback.
- **Testing & Emulation Fallbacks**:
  - Image gallery picker to select existing photos.
  - 1-tap sample photo generator creating vertical 1080×1920 story photos for emulators or desktop test environments without physical camera hardware.

### 2. Freehand Drawing Canvas
- **Smooth Bezier Strokes**: Custom painter rendering drag points with quadratic bezier curve interpolation, round stroke caps, and joins.
- **Instagram-Style Color Palette**: 12 vibrant story colors (white, black, neon pink, crimson, orange, yellow, green, cyan, blue, purple, violet, brown).
- **Brush Controls**:
  - Quick stroke width presets (`Fine` 3px, `Medium` 7px, `Bold` 14px).
  - Dedicated eraser mode.
  - Reversible stroke undo stack and clear-all action.

### 3. Project Status Stickers Library (Figma Asset Pack)
- **40 Project Status Stickers**: Directly modeled after the [Figma Project Status Stickers](https://www.figma.com/design/Ul8AkOtTiNQa6uHNumE0xI/Project-Status-Stickers) design:
  - **Pop Expressions**: `THANKS` (speech bubble), `WOW!` (starburst), `PEACE` (hand sign), `HOT!` (skull flame), `OMG!`, `COOL`, `SUPER!`, `LOVE IT`.
  - **Project Status**: `DONE!`, `APPROVED`, `IN PROGRESS`, `URGENT!`, `IN REVIEW`, `BLOCKED`, `IDEA!`, `W.I.P.`, `LGTM 👍`, `SHIP IT! 🚀`, `BUG! 🐛`, `FIXED`, `TO DO`, `SUCCESS`, `FAIL`, `100%`, `DEADLINE`, `PRIORITY #1`, `DEPLOYED`, `RELEASED`, `TESTING`, etc.
- **Interactive Multi-Touch Gestures**:
  - **Drag**: 1-finger repositioning across the canvas.
  - **Pinch**: 2-finger scale up/down (clamped between 0.4× and 3.5×).
  - **Rotate**: 2-finger rotational transformation.
  - **Selection & Deletion**: Tap to bring forward, show editing boundary, and tap the red (X) button to remove.
- **Sticker Picker Bottom Sheet**: Filterable by categories (`Status`, `Expressions`, `Workflow`) and live text search.

### 4. Caption Input & Typography
- **Fullscreen Story Text Editor**:
  - 5 Typography styles: `MODERN` (Poppins), `CLASSIC` (Playfair Display), `NEON` (VT323 glow), `TYPEWRITER` (Courier Prime), and `STRONG` (Bebas Neue).
  - Background highlight pill toggle (transparent vs. filled badge).
  - Color palette selection.
- **Canvas Placement**: Freely draggable, scalable, rotatable, and editable by tapping.
- **Clipboard Sync**: Captions are automatically copied to the device clipboard upon sharing so users can paste them using Instagram's native fonts.

### 5. Direct Instagram Stories Sharing (No Native Share Sheet)
- **Bypasses OS Share Sheets**: Directly opens the Instagram Story composer without displaying Android's `Intent.createChooser` or iOS's `UIActivityViewController`.
- **Android Intent**:
  - Uses `com.instagram.share.ADD_TO_STORY` explicitly targeting package `com.instagram.android`.
  - Shares the rendered canvas via Android `FileProvider` with `FLAG_GRANT_READ_URI_PERMISSION`.
  - Passes gradient background colors and deep link/caption URL.
- **iOS URL Scheme**:
  - Uses `instagram-stories://share?source_application=...`.
  - Passes the story image through `UIPasteboard` under `com.instagram.sharedSticker.backgroundImage` with a 5-minute expiration timer.
- **High-Resolution Export**: Uses `RepaintBoundary` at 3.0× retina pixel ratio to output high-resolution PNGs without active selection borders.

### 6. Export, Discard & Smooth Transition
- **Discard Confirmation**: Shows a confirmation dialog before discarding unexported edits and returning to the camera.
- **Local Save**: Dedicated "Save" button to export and save the rendered story image to device storage.
- **Transition Modal**: Displays an animated Instagram story ring loader, clipboard status notification, and fallback options if Instagram is not installed.

---

## 🏗️ Clean Code Architecture

The codebase adheres strictly to Clean Architecture principles, ensuring separation of concerns and high testability:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Instagram brand gradients & editor palettes
│   │   └── app_constants.dart        # Platform channel constants & canvas defaults
│   ├── errors/
│   │   ├── exceptions.dart           # Data layer exceptions
│   │   └── failures.dart             # Domain layer failures
│   ├── platform/
│   │   └── instagram_story_channel.dart # MethodChannel bridge for Android & iOS
│   ├── theme/
│   │   └── app_theme.dart            # Dark theme & typography styling
│   └── utils/
│       └── image_saver.dart          # High-resolution RepaintBoundary image exporter
│
├── features/
│   ├── camera/
│   │   ├── domain/repositories/
│   │   │   └── camera_repository.dart
│   │   ├── data/repositories/
│   │   │   └── camera_repository_impl.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── camera_cubit.dart
│   │       │   └── camera_state.dart
│   │       ├── pages/
│   │       │   └── camera_page.dart
│   │       └── widgets/
│   │           └── camera_shutter_button.dart
│   │
│   ├── canvas/
│   │   ├── domain/entities/
│   │   │   ├── drawing_stroke.dart
│   │   │   ├── sticker_item.dart
│   │   │   └── caption_model.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── canvas_cubit.dart
│   │       │   └── canvas_state.dart
│   │       ├── pages/
│   │       │   └── photo_canvas_page.dart
│   │       └── widgets/
│   │           ├── drawing_painter.dart
│   │           ├── interactive_sticker_widget.dart
│   │           ├── interactive_caption_widget.dart
│   │           ├── color_palette_bar.dart
│   │           ├── caption_input_dialog.dart
│   │           └── discard_dialog.dart
│   │
│   ├── stickers/
│   │   ├── domain/entities/
│   │   │   └── sticker_definition.dart
│   │   ├── data/datasources/
│   │   │   └── project_status_stickers_catalog.dart # 40 Figma status stickers
│   │   └── presentation/widgets/
│   │       ├── sticker_badge_widget.dart
│   │       └── sticker_picker_sheet.dart
│   │
│   └── instagram_share/
│       ├── domain/repositories/
│       │   └── instagram_share_repository.dart
│       ├── data/repositories/
│       │   └── instagram_share_repository_impl.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── instagram_share_cubit.dart
│           │   └── instagram_share_state.dart
│           └── widgets/
│               └── instagram_share_modal.dart
│
└── main.dart                          # App entry point with MultiBlocProvider
```

---

## 🔄 State Management (Cubit)

State management is powered by `flutter_bloc` with immutable states extending `Equatable`:

| Cubit | Responsibilities | States |
|---|---|---|
| **`CameraCubit`** | Manages camera lifecycle, front/back camera flipping, flash modes, capture, gallery picking, and sample generation. | `CameraStatus.initial`, `loading`, `ready`, `capturing`, `captured`, `error` |
| **`CanvasCubit`** | Tracks drawing strokes, undo stack, active tool (`brush`, `eraser`, `text`), active color, brush width, placed stickers, selected sticker, caption model, and image export. | `CanvasState` (immutable model containing strokes, stickers, caption, tools, export path) |
| **`InstagramShareCubit`** | Coordinates canvas export, caption clipboard sync, native intent invocation, and fallback handling. | `InstagramShareInitial`, `InstagramShareLoading`, `InstagramShareSuccess`, `InstagramShareNotInstalled`, `InstagramShareSimulated`, `InstagramShareFailure` |

---

## 📱 Platform Configuration Details

### Android
- **Targeting Intent**: `com.instagram.share.ADD_TO_STORY`
- **Target Package**: `com.instagram.android`
- **FileProvider Configuration**: Configured in `android/app/src/main/res/xml/filepaths.xml` with authority `${applicationId}.fileprovider`.
- **Queries & Permissions** in `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
  <queries>
      <package android:name="com.instagram.android" />
      <intent>
          <action android:name="com.instagram.share.ADD_TO_STORY" />
          <data android:mimeType="image/*" />
      </intent>
  </queries>
  ```
- **Kotlin Channel Implementation**: Handled directly in `android/app/src/main/kotlin/com/example/instagram_stories/MainActivity.kt`.

### iOS
- **URL Scheme**: `instagram-stories://share`
- **Pasteboard Item**: `com.instagram.sharedSticker.backgroundImage`
- **Info.plist Configuration**:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>This app requires camera access to capture photos for your Instagram Stories.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>This app requires photo library access to choose photos to edit.</string>
  <key>LSApplicationQueriesSchemes</key>
  <array>
      <string>instagram-stories</string>
      <string>instagram</string>
  </array>
  ```
- **Swift Channel Implementation**: Handled directly in `ios/Runner/AppDelegate.swift`.

---

## 🚀 Getting Started

### 📲 Download Pre-built Release APK & Demo
To test on your device immediately without compiling from source:
- **Release APK (Google Drive)**: [Download `app-release.apk`](https://drive.google.com/file/d/1Zg7asT5z2RM-pxn8qTskf-kiUoFdbh4b/view?usp=sharing)
- **Demo Video (Google Drive)**: [Watch Video Walkthrough](https://drive.google.com/file/d/1EMHdaVpAtGeMYtqkXuqAlocXXsN-HA1y/view?usp=sharing)
- **Install via ADB**:
  ```bash
  adb install -r app-release.apk
  ```

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.22+ or 3.41+)
- Android Studio / Xcode configured for mobile builds
- Physical Android or iOS device with Instagram installed (for native intent testing)

### Installation
1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd instagram_stories
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App
- **Run on connected phone or emulator**:
  ```bash
  flutter run
  ```
- **Run on macOS Desktop (for UI & canvas testing)**:
  ```bash
  flutter run -d macos
  ```

### Running Tests & Static Analysis
- **Run automated test suite**:
  ```bash
  flutter test
  ```
- **Run static analysis**:
  ```bash
  flutter analyze
  ```
