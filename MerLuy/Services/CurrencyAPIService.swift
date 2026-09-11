import Foundation

struct CurrencyRatesResponse: Decodable {
    let date: String
    let base: String
    let rates: [String: Double]
}

@MainActor
final class CurrencyAPIService: ObservableObject {
    @Published private(set) var rates: [String: Double] = [:]
    @Published private(set) var updatedAt: Date?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func fetchRates(base: String = "USD") async {
        guard !isLoading else { return }
        guard var components = URLComponents(string: "https://api.frankfurter.app/latest") else { return }
        components.queryItems = [
            URLQueryItem(name: "from", value: base)
        ]
        guard let url = components.url else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let payload = try JSONDecoder().decode(CurrencyRatesResponse.self, from: data)
            rates = payload.rates
            if rates["KHR"] == nil { rates["KHR"] = 4100.0 }
            updatedAt = ISO8601DateFormatter().date(from: payload.date)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rate(from: Currency, to: Currency) -> Double? {
        let destinationRate = rates[to.code] ?? (to.code == "KHR" ? 4100.0 : nil)
        guard let destinationRate else { return nil }
        guard from.code != "USD" else { return destinationRate }
        let sourceRate = rates[from.code] ?? (from.code == "KHR" ? 4100.0 : nil)
        guard let sourceRate, sourceRate != 0 else { return nil }
        return destinationRate / sourceRate
    }

}
