import Foundation

@MainActor
final class LicenseService: ObservableObject {
    @Published private(set) var isChecking = false
    @Published private(set) var resultMessage: String?
    @Published private(set) var isValid = false

    func check(key: String) async {
        isChecking = true
        resultMessage = nil
        isValid = false

        let normalizedKey = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        try? await Task.sleep(nanoseconds: 350_000_000)

        let localTestKeys = (1...10).map { String(format: "MERLUY-PRO-%03d", $0) } + ["MERLUY-PRO-BETA"]
        isValid = localTestKeys.contains(normalizedKey)
        resultMessage = isValid ? "License verified. Pro is ready on this device." : "License not found. Contact the owner for a valid key."
        isChecking = false
    }
}
