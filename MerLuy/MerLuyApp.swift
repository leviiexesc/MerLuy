import SwiftUI

@main
struct MerLuyApp: App {
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
        }
    }
}
