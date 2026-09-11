import SwiftUI

struct AdminView: View {
    private enum Section: String, CaseIterable {
        case dashboard = "Dashboard"
        case notifications = "Notifications"
    }

    @EnvironmentObject private var notifications: NotificationService
    @EnvironmentObject private var language: LanguageManager
    @EnvironmentObject private var profile: UserProfile
    @EnvironmentObject private var usage: AppUsageStore
    @EnvironmentObject private var currencyAPI: CurrencyAPIService
    @State private var section: Section = .dashboard
    @State private var title = "MerLuy update"
    @State private var message = "Your exchange rates have been refreshed."
    @State private var serverURLText = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                Picker("Admin section", selection: $section) {
                    ForEach(Section.allCases, id: \.self) { item in Text(item.rawValue).tag(item) }
                }
                .pickerStyle(.segmented)
                .frame(minHeight: 44)

                switch section {
                case .dashboard: dashboard
                case .notifications: notificationComposer
                }
                Text("Private Admin Workspace")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MerLuyTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 20)
        }
        .onAppear {
            serverURLText = notifications.serverURL
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(language.language.text("Admin Panel"))
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("Manage MerLuy from one clear workspace")
                .font(.system(size: 13))
                .foregroundStyle(MerLuyTheme.textSecondary)
        }
    }

    private var dashboard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                MetricCard(title: "App opens", value: "\(usage.homeOpens)", icon: "person.2.fill", color: .cyan)
                MetricCard(title: "Conversions", value: "\(usage.conversions)", icon: "arrow.left.arrow.right", color: MerLuyTheme.indigo)
            }
            HStack(spacing: 12) {
                MetricCard(title: "Exchange opens", value: "\(usage.exchangeOpens)", icon: "chart.line.uptrend.xyaxis", color: MerLuyTheme.positive)
                MetricCard(title: "Rates API", value: currencyAPI.rates.isEmpty ? "Offline" : "Live", icon: "antenna.radiowaves.left.and.right", color: currencyAPI.rates.isEmpty ? MerLuyTheme.negative : MerLuyTheme.positive)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("Usage overview").font(.system(size: 16, weight: .bold))
                UsageRow(label: "Home opens", value: "\(usage.homeOpens)", progress: min(Double(usage.homeOpens) / 100.0, 1.0))
                UsageRow(label: "Exchange sessions", value: "\(usage.exchangeOpens)", progress: min(Double(usage.exchangeOpens) / 100.0, 1.0))
                UsageRow(label: "Plan", value: profile.isPro ? "Pro Beta" : "Free", progress: profile.isPro ? 1.0 : 0.25)
            }
            .padding(16)
            .glassCard(radius: 18)
            Text("Dashboard data is collected locally on this device. Add a backend later for multi-user analytics.")
                .font(.system(size: 11))
                .foregroundStyle(MerLuyTheme.textSecondary)
        }
    }

    private var notificationComposer: some View {
        VStack(alignment: .leading, spacing: 14) {
            AdminField(label: "Title", text: $title)
            AdminField(label: "Message", text: $message, axis: .vertical)
            VStack(alignment: .leading, spacing: 7) {
                Text("Server URL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(MerLuyTheme.textSecondary)
                TextField("https://your-free-server.example.com", text: $serverURLText)
                    .font(.system(size: 13))
                    .padding(13)
                    .frame(minHeight: 48)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .onChange(of: serverURLText) { newValue in
                        notifications.setServerURL(newValue)
                    }
            }
            Button {
                Task {
                    notifications.setServerURL(serverURLText)
                    await notifications.sendRemoteNotification(title: title, message: message)
                }
            } label: {
                Label("Send Notification", systemImage: "paperplane.fill")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
            }
            .foregroundStyle(.white)
            .background(MerLuyTheme.indigo)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            if let statusMessage = notifications.statusMessage {
                Label(statusMessage, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(MerLuyTheme.positive)
            }
            Text("This sends the same alert to iPhone and Android when the free backend is connected. Sound plays in-app and outside the app.")
                .font(.system(size: 11))
                .foregroundStyle(MerLuyTheme.textSecondary)
        }
        .padding(16)
        .glassCard(radius: 20)
    }

}

private struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).foregroundStyle(color).font(.system(size: 16, weight: .bold))
            Text(value).font(.system(size: 22, weight: .bold, design: .rounded))
            Text(title).font(.system(size: 10)).foregroundStyle(MerLuyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCard(radius: 17)
    }
}

private struct UsageRow: View {
    let label: String
    let value: String
    let progress: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack { Text(label).font(.system(size: 12)); Spacer(); Text(value).font(.system(size: 12, weight: .bold)) }
            ProgressView(value: progress).tint(MerLuyTheme.indigo)
        }
    }
}

private struct AdminField: View {
    let label: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label.uppercased()).font(.system(size: 10, weight: .bold)).foregroundStyle(MerLuyTheme.textSecondary)
            TextField(label, text: $text, axis: axis)
                .lineLimit(axis == .vertical ? 4 : 1)
                .font(.system(size: 14))
                .padding(13)
                .frame(minHeight: 48)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 13))
        }
    }
}
