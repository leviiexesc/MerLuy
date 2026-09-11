import SwiftUI

@main
struct MerLuyApp: App {
    @StateObject private var theme = ThemeManager()
    @StateObject private var currencyAPI = CurrencyAPIService()
    @StateObject private var language = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .environmentObject(currencyAPI)
                .environmentObject(language)
                .preferredColorScheme(theme.isDarkMode ? .dark : .light)
        }
    }
}
