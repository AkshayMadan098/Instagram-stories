import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "com.example.instagram_stories/share"
  private var isChannelConfigured = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      setupMethodChannel(messenger: controller.binaryMessenger)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    setupMethodChannel(messenger: engineBridge.binaryMessenger)
  }

  private func setupMethodChannel(messenger: FlutterBinaryMessenger) {
    guard !isChannelConfigured else { return }
    isChannelConfigured = true

    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "isInstagramInstalled" {
        if let url = URL(string: "instagram-stories://share") {
          result(UIApplication.shared.canOpenURL(url))
        } else {
          result(false)
        }
      } else if call.method == "shareToInstagramStory" {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Image path is missing", details: nil))
          return
        }

        let bundleId = Bundle.main.bundleIdentifier ?? "com.example.instagram_stories"
        guard let urlScheme = URL(string: "instagram-stories://share?source_application=\(bundleId)") else {
          result(FlutterError(code: "INVALID_URL", message: "Invalid URL scheme", details: nil))
          return
        }

        guard UIApplication.shared.canOpenURL(urlScheme) else {
          result("instagram_not_installed")
          return
        }

        guard let image = UIImage(contentsOfFile: imagePath),
              let imageData = image.pngData() else {
          result(FlutterError(code: "IMAGE_LOAD_FAILED", message: "Failed to load image file", details: nil))
          return
        }

        let pasteboardItems: [[String: Any]] = [
          [
            "com.instagram.sharedSticker.backgroundImage": imageData
          ]
        ]

        let pasteboardOptions = [
          UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
        ]

        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)

        UIApplication.shared.open(urlScheme, options: [:]) { success in
          if success {
            result("success")
          } else {
            result(FlutterError(code: "OPEN_FAILED", message: "Failed to open Instagram Stories", details: nil))
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
