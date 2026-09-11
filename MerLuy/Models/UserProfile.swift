import Foundation

@MainActor
final class UserProfile: ObservableObject {
    @Published var isLoggedIn: Bool {
        didSet { UserDefaults.standard.set(isLoggedIn, forKey: "merluy.user.loggedIn") }
    }
    @Published var name: String {
        didSet { UserDefaults.standard.set(name, forKey: "merluy.user.name") }
    }
    @Published var email: String {
        didSet { UserDefaults.standard.set(email, forKey: "merluy.user.email") }
    }
    @Published var isVerified: Bool {
        didSet { UserDefaults.standard.set(isVerified, forKey: "merluy.user.verified") }
    }
    @Published var isPro: Bool {
        didSet { UserDefaults.standard.set(isPro, forKey: "merluy.user.pro") }
    }
    @Published var imageData: Data? {
        didSet { UserDefaults.standard.set(imageData, forKey: "merluy.user.image") }
    }

    init() {
        let defaults = UserDefaults.standard
        isLoggedIn = defaults.bool(forKey: "merluy.user.loggedIn")
        name = defaults.string(forKey: "merluy.user.name") ?? "MerLuy User"
        email = defaults.string(forKey: "merluy.user.email") ?? ""
        isVerified = defaults.bool(forKey: "merluy.user.verified")
        isPro = defaults.bool(forKey: "merluy.user.pro") || defaults.bool(forKey: "merluy.proActivated")
        imageData = defaults.data(forKey: "merluy.user.image")
    }

    func register(name: String, email: String) {
        self.name = name
        self.email = email
        isLoggedIn = true
        isVerified = false
    }

    func logOut() {
        isLoggedIn = false
    }

    func verify() {
        isVerified = true
    }
}
