import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var language: LanguageManager
    @AppStorage("merluy.adminAuthenticated") private var adminAuthenticated = false
    @State private var showingAdminAccess = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.language.text("Settings")).font(.system(size: 25, weight: .bold, design: .rounded))
                    Text(language.language.text("Manage your preferences and profiles")).font(.system(size: 13)).foregroundStyle(MerLuyTheme.textSecondary)
                }
                SettingsSection(title: language.language.text("Account")) {
                    SettingsRow(icon: "person", title: language.language.text("Profile Details"), showsChevron: true)
                    SettingsRow(icon: "bell", title: language.language.text("Notifications"), showsChevron: true)
                }
                SettingsSection(title: language.language.text("Preferences")) {
                    SettingsRow(icon: "creditcard", title: language.language.text("Default Currency"), detail: "USD ($)", showsChevron: true)
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
                    Button { showingAdminAccess = true } label: {
                        SettingsRow(icon: "person.badge.key", title: language.language.text("Admin Account"), detail: adminAuthenticated ? "Signed in" : "Login / Register", showsChevron: true)
                    }
                    .buttonStyle(.plain)
                }
                SettingsSection(title: language.language.text("About")) {
                    SettingsRow(icon: "star", title: language.language.text("Rate MerLuy"), showsChevron: true)
                    SettingsRow(icon: "lock", title: language.language.text("Privacy Policy"), showsChevron: true)
                    SettingsRow(icon: "info.circle", title: language.language.text("Version"), detail: "v26.4.2")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .sheet(isPresented: $showingAdminAccess) {
            AdminAccessView(isAuthenticated: $adminAuthenticated)
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
