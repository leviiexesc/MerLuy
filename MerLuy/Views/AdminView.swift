import SwiftUI

struct AdminView: View {
    @EnvironmentObject private var notifications: NotificationService
    @EnvironmentObject private var language: LanguageManager
    @State private var title = "MerLuy update"
    @State private var message = "Your exchange rates have been refreshed."

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(language.language.text("Admin Panel"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Text(language.language.text("Send a notification to this phone"))
                        .font(.system(size: 13))
                        .foregroundStyle(MerLuyTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    AdminField(label: language.language.text("Title"), text: $title)
                    AdminField(label: language.language.text("Message"), text: $message, axis: .vertical)

                    Button {
                        Task {
                            await notifications.sendLocalNotification(title: title, message: message)
                        }
                    } label: {
                        Label(language.language.text("Send Notification"), systemImage: "paperplane.fill")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 48)
                    }
                    .foregroundStyle(.white)
                    .background(MerLuyTheme.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(16)
                .glassCard(radius: 20)

                if let statusMessage = notifications.statusMessage {
                    Label(statusMessage, systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(MerLuyTheme.positive)
                        .padding(.horizontal, 4)
                }

                Text(language.language.text("This demo sends a local notification. Remote notifications need an Apple Push Notification server."))
                    .font(.system(size: 11))
                    .foregroundStyle(MerLuyTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
    }
}

private struct AdminField: View {
    let label: String
    @Binding var text: String
    var axis: Axis = .horizontal

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(MerLuyTheme.textSecondary)
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
