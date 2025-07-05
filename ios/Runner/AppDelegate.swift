import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // var google_api_key: String = Bundle.main.infoDictionary?["GOOGLE_API_KEY"] as? String ?? ""
    if let google_api_key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String {
      GMSServices.provideAPIKey("\(google_api_key)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
