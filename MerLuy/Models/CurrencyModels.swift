import Foundation

struct Currency: Identifiable, Hashable {
    let id: String
    let code: String
    let name: String
    let flag: String
}

struct ExchangeRate: Identifiable {
    let id = UUID()
    let from: Currency
    let to: Currency
    let rate: Double
    let change: Double

    var pairName: String { "\(from.code) -> \(to.code)" }
}

enum SampleData {
    static let usd = Currency(id: "usd", code: "USD", name: "US Dollar", flag: "🇺🇸")
    static let eur = Currency(id: "eur", code: "EUR", name: "Euro", flag: "🇪🇺")
    static let gbp = Currency(id: "gbp", code: "GBP", name: "British Pound", flag: "🇬🇧")
    static let jpy = Currency(id: "jpy", code: "JPY", name: "Japanese Yen", flag: "🇯🇵")
    static let khr = Currency(id: "khr", code: "KHR", name: "Cambodian Riel", flag: "🇰🇭")

    static let currencies = [usd, eur, gbp, jpy, khr]
    static let rates = [
        ExchangeRate(from: usd, to: eur, rate: 0.9241, change: 0.18),
        ExchangeRate(from: gbp, to: jpy, rate: 191.56, change: -0.45),
        ExchangeRate(from: eur, to: usd, rate: 1.0821, change: 0.12)
    ]
}
