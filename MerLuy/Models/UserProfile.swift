import Foundation

@MainActor
final class UserProfile: ObservableObject {
    enum Role: String {
        case user = "User"
        case admin = "Admin"
    }
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
    @Published private(set) var role: Role {
        didSet { UserDefaults.standard.set(role.rawValue, forKey: "merluy.user.role") }
    }

    var isAdmin: Bool { isLoggedIn && role == .admin }

    init() {
        let defaults = UserDefaults.standard
        isLoggedIn = defaults.bool(forKey: "merluy.user.loggedIn")
        name = defaults.string(forKey: "merluy.user.name") ?? "MerLuy User"
        email = defaults.string(forKey: "merluy.user.email") ?? ""
        isVerified = defaults.bool(forKey: "merluy.user.verified")
        isPro = defaults.bool(forKey: "merluy.user.pro") || defaults.bool(forKey: "merluy.proActivated")
        imageData = defaults.data(forKey: "merluy.user.image")
        role = Role(rawValue: defaults.string(forKey: "merluy.user.role") ?? "User") ?? .user
    }

    func register(name: String, email: String) {
        self.name = name
        self.email = email
        isLoggedIn = true
        isVerified = false
        role = .user
    }

    func login(name: String, email: String, password: String) -> Bool {
        guard email.caseInsensitiveCompare("admin@gmail.com") == .orderedSame,
              password == "admin998877$" else { return false }
        self.name = name.isEmpty ? "Admin" : name
        self.email = email
        self.role = .admin
        self.isVerified = true
        self.isLoggedIn = true
        return true
    }

    func loginUser(email: String, password: String) -> Bool {
        let registeredEmail = UserDefaults.standard.string(forKey: "merluy.user.email") ?? ""
        guard !email.isEmpty, password.count >= 6, email.caseInsensitiveCompare(registeredEmail) == .orderedSame else { return false }
        self.email = email
        self.name = UserDefaults.standard.string(forKey: "merluy.user.name") ?? email.split(separator: "@").first.map(String.init) ?? "MerLuy User"
        self.role = .user
        self.isLoggedIn = true
        return true
    }

    func logOut() {
        isLoggedIn = false
        role = .user
    }

    func verify() {
        isVerified = true
    }
}
