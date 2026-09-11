import SwiftUI

struct MerLuyTheme {
    static let background = Color(red: 0.055, green: 0.055, blue: 0.11)
    static let surface = Color(red: 0.12, green: 0.105, blue: 0.22)
    static let surfaceLight = Color(red: 0.17, green: 0.15, blue: 0.30)
    static let indigo = Color(red: 0.42, green: 0.39, blue: 1.0)
    static let positive = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let negative = Color(red: 0.97, green: 0.44, blue: 0.44)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.57, green: 0.55, blue: 0.68)
    static let divider = Color.white.opacity(0.08)

    static let glow = LinearGradient(
        colors: [indigo.opacity(0.25), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let card = LinearGradient(
        colors: [surfaceLight.opacity(0.72), surface.opacity(0.78)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

final class ThemeManager: ObservableObject {
    @Published var isDarkMode = true
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case khmer = "Khmer"

    var id: String { rawValue }

    func text(_ english: String) -> String {
        guard self == .khmer else { return english }
        switch english {
        case "Settings": return "ការកំណត់"
        case "Manage your preferences and profiles": return "គ្រប់គ្រងចំណូលចិត្ត និងប្រវត្តិរូប"
        case "Account": return "គណនី"
        case "Profile Details": return "ព័ត៌មានប្រវត្តិរូប"
        case "Notifications": return "ការជូនដំណឹង"
        case "Preferences": return "ចំណូលចិត្ត"
        case "Default Currency": return "រូបិយប័ណ្ណលំនាំដើម"
        case "Dark Theme": return "ផ្ទៃងងឹត"
        case "Language": return "ភាសា"
        case "About": return "អំពីកម្មវិធី"
        case "Rate MerLuy": return "វាយតម្លៃ MerLuy"
        case "Privacy Policy": return "គោលការណ៍ឯកជនភាព"
        case "Version": return "កំណែ"
        case "Exchange": return "ប្តូររូបិយប័ណ្ណ"
        case "Convert between world currencies": return "ប្តូររូបិយប័ណ្ណជុំវិញពិភពលោក"
        case "Amount": return "ចំនួនទឹកប្រាក់"
        case "From": return "ពី"
        case "To": return "ទៅ"
        case "Convert Amount": return "ប្តូរចំនួនទឹកប្រាក់"
        case "Result": return "លទ្ធផល"
        case "Welcome to MerLuy": return "សូមស្វាគមន៍មកកាន់ MerLuy"
        case "Real-time liquid-grade global transactions": return "ប្រតិបត្តិការរូបិយប័ណ្ណសកលទាន់ពេលវេលា"
        case "Live Markets": return "ទីផ្សារផ្ទាល់"
        case "Quick Convert": return "ប្តូររហ័ស"
        case "You send": return "អ្នកផ្ញើ"
        case "You receive": return "អ្នកទទួល"
        default: return english
        }
    }
}

final class LanguageManager: ObservableObject {
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "merluy.language") }
    }

    init() {
        let savedValue = UserDefaults.standard.string(forKey: "merluy.language")
        language = AppLanguage(rawValue: savedValue ?? "") ?? .english
    }
}

struct GlassCard: ViewModifier {
    var radius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(MerLuyTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: Color.black.opacity(0.24), radius: 18, y: 8)
    }
}

extension View {
    func glassCard(radius: CGFloat = 18) -> some View {
        modifier(GlassCard(radius: radius))
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            MerLuyTheme.background.ignoresSafeArea()
            Circle()
                .fill(MerLuyTheme.indigo.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -140, y: -280)
            Circle()
                .fill(Color.purple.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 160, y: 260)
        }
    }
}

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(MerLuyTheme.textSecondary)
    }
}
