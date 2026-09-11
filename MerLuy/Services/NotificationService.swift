import Foundation
import UserNotifications

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date = Date()
}

@MainActor
final class NotificationService: ObservableObject {
    @Published private(set) var statusMessage: String?
    @Published private(set) var notifications: [AppNotification] = []

    var unreadCount: Int { notifications.count }

    func sendLocalNotification(title: String, message: String) async {
        notifications.insert(AppNotification(title: title, message: message), at: 0)
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            do {
                guard try await center.requestAuthorization(options: [.alert, .sound, .badge]) else {
                    statusMessage = "Notification permission was not granted."
                    return
                }
            } catch {
                statusMessage = error.localizedDescription
                return
            }
        } else if settings.authorizationStatus == .denied {
            statusMessage = "Enable notifications in iPhone Settings to send alerts."
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "merluy-admin-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        do {
            try await center.add(request)
            statusMessage = "Notification scheduled for this phone."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func clearNotifications() {
        notifications.removeAll()
    }
}
