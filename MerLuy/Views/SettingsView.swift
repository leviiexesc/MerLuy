import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings").font(.system(size: 25, weight: .bold, design: .rounded))
                    Text("Manage your preferences and profiles").font(.system(size: 13)).foregroundStyle(MerLuyTheme.textSecondary)
                }
                SettingsSection(title: "Account") {
                    SettingsRow(icon: "person", title: "Profile Details", showsChevron: true)
                    SettingsRow(icon: "bell", title: "Notifications", showsChevron: true)
                }
                SettingsSection(title: "Preferences") {
                    SettingsRow(icon: "creditcard", title: "Default Currency", detail: "USD ($)", showsChevron: true)
                    SettingsRow(icon: "moon", title: "Dark Theme") {
                        Toggle("", isOn: $theme.isDarkMode).labelsHidden().tint(MerLuyTheme.indigo)
                    }
                    SettingsRow(icon: "globe", title: "Language", detail: "English", showsChevron: true)
                }
                SettingsSection(title: "About") {
                    SettingsRow(icon: "star", title: "Rate MerLuy", showsChevron: true)
                    SettingsRow(icon: "lock", title: "Privacy Policy", showsChevron: true)
                    SettingsRow(icon: "info.circle", title: "Version", detail: "v26.4.2")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
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
