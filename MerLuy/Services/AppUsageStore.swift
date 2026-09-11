import Foundation

@MainActor
final class AppUsageStore: ObservableObject {
    @Published private(set) var homeOpens: Int
    @Published private(set) var exchangeOpens: Int
    @Published private(set) var conversions: Int

    init() {
        let defaults = UserDefaults.standard
        homeOpens = defaults.integer(forKey: "merluy.usage.homeOpens")
        exchangeOpens = defaults.integer(forKey: "merluy.usage.exchangeOpens")
        conversions = defaults.integer(forKey: "merluy.usage.conversions")
    }

    func recordHomeOpen() {
        homeOpens += 1
        save()
    }

    func recordExchangeOpen() {
        exchangeOpens += 1
        save()
    }

    func recordConversion() {
        conversions += 1
        save()
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(homeOpens, forKey: "merluy.usage.homeOpens")
        defaults.set(exchangeOpens, forKey: "merluy.usage.exchangeOpens")
        defaults.set(conversions, forKey: "merluy.usage.conversions")
    }
}
