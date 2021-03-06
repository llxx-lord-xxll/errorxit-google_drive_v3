import Flutter
import UIKit

public class SwiftGoogleDriveV3Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "google_drive_v3", binaryMessenger: registrar.messenger())
    let instance = SwiftGoogleDriveV3Plugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
