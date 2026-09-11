import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var language: LanguageManager
    @Environment(\.requestReview) private var requestReview
    @AppStorage("merluy.defaultCurrency") private var defaultCurrency = "USD"
    @State private var showingPrivacy = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.language.text("Settings")).font(.system(size: 25, weight: .bold, design: .rounded))
                    Text(language.language.text("Manage your preferences and profiles")).font(.system(size: 13)).foregroundStyle(MerLuyTheme.textSecondary)
                }
                SettingsSection(title: language.language.text("Preferences")) {
                    SettingsRow(icon: "creditcard", title: language.language.text("Default Currency")) {
                        CurrencyDropdown(selection: $defaultCurrency)
                    }
                    SettingsRow(icon: "moon", title: language.language.text("Dark Theme")) {
                        Toggle("", isOn: $theme.isDarkMode).labelsHidden().tint(MerLuyTheme.indigo)
                    }
                    SettingsRow(icon: "globe", title: language.language.text("Language")) {
                        Menu {
                            ForEach(AppLanguage.allCases) { option in
                                Button(option.rawValue) { language.language = option }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(language.language.rawValue).font(.system(size: 11)).foregroundStyle(MerLuyTheme.textSecondary)
                                Image(systemName: "chevron.right").font(.system(size: 9, weight: .bold)).foregroundStyle(MerLuyTheme.textSecondary)
                            }
                        }
                    }
                }
                SettingsSection(title: language.language.text("About")) {
                    Button { requestReview() } label: {
                        SettingsRow(icon: "star.fill", title: language.language.text("Rate MerLuy"), detail: "App Store", showsChevron: true)
                    }
                    .buttonStyle(.plain)
                    Button { showingPrivacy = true } label: {
                        SettingsRow(icon: "lock.fill", title: language.language.text("Privacy Policy"), showsChevron: true)
                    }
                    .buttonStyle(.plain)
                    SettingsRow(icon: "info.circle.fill", title: language.language.text("Version"), detail: "V Beta")
                    SettingsRow(icon: "hammer.fill", title: "Developed by", detail: "Chiro")
                }
                VStack(spacing: 5) {
                    Text("MerLuy")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Text("Developed by Chiro · V Beta")
                        .font(.system(size: 11))
                        .foregroundStyle(MerLuyTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .sheet(isPresented: $showingPrivacy) { PrivacyPolicyView() }
    }
}

private struct CurrencyDropdown: View {
    @Binding var selection: String

    var body: some View {
        Menu {
            ForEach(SampleData.currencies) { currency in
                Button { selection = currency.code } label: {
                    Text("\(currency.flag)  \(currency.code) - \(currency.name)")
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(selection)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(MerLuyTheme.textSecondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(MerLuyTheme.indigo)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 42)
            .background(MerLuyTheme.indigo.opacity(0.12))
            .clipShape(Capsule())
        }
        .accessibilityLabel("Default currency")
    }
}

private struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Privacy Policy")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        PrivacyParagraph(title: "Your data", copy: "MerLuy stores profile preferences, language, theme, and beta plan status locally on your device for this demo.")
                        PrivacyParagraph(title: "Exchange rates", copy: "Live exchange rates are requested from the free Frankfurter API. No payment details are collected by MerLuy.")
                        PrivacyParagraph(title: "Notifications", copy: "Notification permission is requested only when you use the notification feature. Local notifications stay on your device.")
                        PrivacyParagraph(title: "Contact", copy: "MerLuy is developed by Chiro. This beta policy may change before production release.")
                    }
                    .padding(20)
                }
            }
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } } }
        }
        .preferredColorScheme(.dark)
    }
}

private struct PrivacyParagraph: View {
    let title: String
    let copy: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 15, weight: .bold))
            Text(copy).font(.system(size: 12)).foregroundStyle(MerLuyTheme.textSecondary)
        }
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title: title)
            VStack(spacing: 0) { content }
                .glassCard(radius: 17)
        }
    }
}

private struct SettingsRow<Accessory: View>: View {
    let icon: String
    let title: String
    var detail: String? = nil
    var showsChevron = false
    @ViewBuilder var accessory: Accessory

    init(icon: String, title: String, detail: String? = nil, showsChevron: Bool = false, @ViewBuilder accessory: () -> Accessory = { EmptyView() }) {
        self.icon = icon
        self.title = title
        self.detail = detail
        self.showsChevron = showsChevron
        self.accessory = accessory()
    }

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(MerLuyTheme.indigo)
                .frame(width: 28, height: 28)
                .background(MerLuyTheme.indigo.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(title).font(.system(size: 12, weight: .medium))
            Spacer()
            if let detail { Text(detail).font(.system(size: 11)).foregroundStyle(MerLuyTheme.textSecondary) }
            accessory
            if showsChevron { Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)).foregroundStyle(MerLuyTheme.textSecondary) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .overlay(alignment: .bottom) { Rectangle().fill(MerLuyTheme.divider).frame(height: 1).padding(.leading, 52) }
    }
}
