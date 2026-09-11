import SwiftUI

struct NotificationCenterView: View {
    @EnvironmentObject private var notifications: NotificationService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                if notifications.notifications.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash").font(.system(size: 34)).foregroundStyle(MerLuyTheme.textSecondary)
                        Text("No notifications yet").font(.system(size: 17, weight: .bold))
                        Text("Updates from MerLuy will appear here.").font(.system(size: 12)).foregroundStyle(MerLuyTheme.textSecondary)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(notifications.notifications) { notification in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "bell.fill").foregroundStyle(MerLuyTheme.indigo).frame(width: 36, height: 36).background(MerLuyTheme.indigo.opacity(0.15)).clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(notification.title).font(.system(size: 14, weight: .bold))
                                        Text(notification.message).font(.system(size: 12)).foregroundStyle(MerLuyTheme.textSecondary)
                                        Text(notification.date, style: .time).font(.system(size: 10)).foregroundStyle(MerLuyTheme.textSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(14).glassCard(radius: 17)
                            }
                        }.padding(16)
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    if !notifications.notifications.isEmpty { Button("Clear") { notifications.clearNotifications() } }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
