import Flutter
import UIKit
import GoogleSignIn
import Sentry
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure Sentry
    SentrySDK.start { options in
        options.dsn = "https://31aedf28c923bcee6fa04c7f90de6d0d@o4510139708735488.ingest.us.sentry.io/4510139709652992"
        options.debug = false
        options.enableAutoSessionTracking = true
        options.sessionTrackingIntervalMillis = 30000
    }
    
    // Configure Google Sign-In
    guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path),
          let clientId = plist["CLIENT_ID"] as? String else {
      fatalError("GoogleService-Info.plist not found or CLIENT_ID missing")
    }
    
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
}
