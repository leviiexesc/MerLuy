import SwiftUI

struct AdminView: View {
    private enum Section: String, CaseIterable {
        case dashboard = "Dashboard"
        case notifications = "Notifications"
        case plans = "Beta Plans"
    }

    @EnvironmentObject private var notifications: NotificationService
    @EnvironmentObject private var language: LanguageManager
    @AppStorage("merluy.adminAuthenticated") private var adminAuthenticated = true
    @State private var section: Section = .dashboard
    @State private var title = "MerLuy update"
    @State private var message = "Your exchange rates have been refreshed."
    @State private var selectedPlan = "Pro Beta"
    @AppStorage("merluy.proActivated") private var didActivatePlan = false
    @State private var licenseKey = ""
    @State private var licenseMessage: String?

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
                case .plans: betaPlans
                }
                Button {
                    adminAuthenticated = false
                } label: {
                    Label("Log Out Admin", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 46)
                }
                .foregroundStyle(MerLuyTheme.negative)
                .background(MerLuyTheme.negative.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 20)
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
                MetricCard(title: "Active users", value: "128", icon: "person.2.fill", color: .cyan)
                MetricCard(title: "Conversions", value: "642", icon: "arrow.left.arrow.right", color: MerLuyTheme.indigo)
            }
            HStack(spacing: 12) {
                MetricCard(title: "KHR volume", value: "៛8.4M", icon: "banknote.fill", color: MerLuyTheme.positive)
                MetricCard(title: "API status", value: "Live", icon: "antenna.radiowaves.left.and.right", color: MerLuyTheme.positive)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("Usage overview").font(.system(size: 16, weight: .bold))
                UsageRow(label: "Home opens", value: "1,284", progress: 0.78)
                UsageRow(label: "Exchange sessions", value: "642", progress: 0.54)
                UsageRow(label: "Khmer language", value: "36%", progress: 0.36)
            }
            .padding(16)
            .glassCard(radius: 18)
            Text("Demo analytics are local sample data. Connect a backend to show real users and usage.")
                .font(.system(size: 11))
                .foregroundStyle(MerLuyTheme.textSecondary)
        }
    }

    private var notificationComposer: some View {
        VStack(alignment: .leading, spacing: 14) {
            AdminField(label: "Title", text: $title)
            AdminField(label: "Message", text: $message, axis: .vertical)
            Button {
                Task { await notifications.sendLocalNotification(title: title, message: message) }
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
            Text("This sends a local notification to the current iPhone. Remote delivery needs APNs and a backend.")
                .font(.system(size: 11))
                .foregroundStyle(MerLuyTheme.textSecondary)
        }
        .padding(16)
        .glassCard(radius: 20)
    }

    private var betaPlans: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Test account plans before launch")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(MerLuyTheme.textSecondary)
            PlanCard(name: "Free", detail: "Basic currency conversion", icon: "person", isSelected: selectedPlan == "Free") {
                selectedPlan = "Free"
            }
            PlanCard(name: "Pro Beta", detail: "Unlimited conversions and priority rates", icon: "sparkles", isSelected: selectedPlan == "Pro Beta") {
                selectedPlan = "Pro Beta"
            }
            if selectedPlan == "Pro Beta" {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pro license key")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(MerLuyTheme.textSecondary)
                    TextField("Enter license key", text: $licenseKey)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 13)
                        .frame(minHeight: 50)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    Button {
                        activatePro()
                    } label: {
                        Text(didActivatePlan ? "Pro Beta Active" : "Activate with License Key")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50)
                    }
                    .foregroundStyle(.white)
                    .background(didActivatePlan ? MerLuyTheme.positive : MerLuyTheme.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    if let licenseMessage {
                        Text(licenseMessage)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(didActivatePlan ? MerLuyTheme.positive : MerLuyTheme.negative)
                    }
                }
                .padding(14)
                .glassCard(radius: 17)
            }
            Text("Beta mode is local only. Test keys: MERLUY-PRO-001 through MERLUY-PRO-010")
                .font(.system(size: 11))
                .foregroundStyle(MerLuyTheme.textSecondary)
        }
    }

    private func activatePro() {
        let normalizedKey = licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let testKeys = (1...10).map { String(format: "MERLUY-PRO-%03d", $0) } + ["MERLUY-PRO-BETA"]
        guard testKeys.contains(normalizedKey) else {
            didActivatePlan = false
            licenseMessage = "That license key is not valid for this beta."
            return
        }
        didActivatePlan = true
        licenseMessage = "Pro Beta activated on this device."
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

private struct PlanCard: View {
    let name: String
    let detail: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).frame(width: 36, height: 36).foregroundStyle(MerLuyTheme.indigo).background(MerLuyTheme.indigo.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 4) { Text(name).font(.system(size: 14, weight: .bold)); Text(detail).font(.system(size: 11)).foregroundStyle(MerLuyTheme.textSecondary) }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle").font(.system(size: 20)).foregroundStyle(isSelected ? MerLuyTheme.positive : MerLuyTheme.textSecondary)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassCard(radius: 17)
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
