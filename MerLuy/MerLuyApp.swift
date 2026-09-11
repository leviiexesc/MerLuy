import SwiftUI
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: .deviceTokenReceived, object: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: .deviceTokenReceived, object: nil)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

extension Notification.Name {
    static let deviceTokenReceived = Notification.Name("merluy.deviceTokenReceived")
}

@main
struct MerLuyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var theme = ThemeManager()
    @StateObject private var currencyAPI = CurrencyAPIService()
    @StateObject private var language = LanguageManager()
    @StateObject private var notifications = NotificationService()
    @StateObject private var profile = UserProfile()
    @StateObject private var usage = AppUsageStore()
    @StateObject private var licenseService = LicenseService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .environmentObject(currencyAPI)
                .environmentObject(language)
                .environmentObject(notifications)
                .environmentObject(profile)
                .environmentObject(usage)
                .environmentObject(licenseService)
                .preferredColorScheme(theme.isDarkMode ? .dark : .light)
                .onAppear {
                    Task {
                        _ = await notifications.requestPermissions()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .deviceTokenReceived)) { output in
                    if let token = output.object as? Data {
                        notifications.registerDeviceToken(token)
                    }
                }
        }
    }
}
