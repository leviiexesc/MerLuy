import Foundation
import UserNotifications
import UIKit

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date = Date()
}

struct RemoteNotificationRequest: Codable {
    let title: String
    let message: String
    let platform: String
    let deviceToken: String?
    let sound: String
}

@MainActor
final class NotificationService: ObservableObject {
    @Published private(set) var statusMessage: String?
    @Published private(set) var notifications: [AppNotification] = []
    @Published private(set) var deviceToken: String?
    @Published private(set) var serverURL: String
    @Published private(set) var isRemoteEnabled = false

    var unreadCount: Int { notifications.count }

    init() {
        let savedURL = UserDefaults.standard.string(forKey: "merluy.server.url") ?? "https://your-free-server.example.com"
        self.serverURL = savedURL
    }

    func setServerURL(_ url: String) {
        let cleaned = url.trimmingCharacters(in: .whitespacesAndNewlines)
        serverURL = cleaned
        UserDefaults.standard.set(cleaned, forKey: "merluy.server.url")
    }

    func registerDeviceToken(_ token: Data) {
        let value = token.map { String(format: "%02.2hhx", $0) }.joined()
        deviceToken = value
        isRemoteEnabled = !value.isEmpty
    }

    func requestPermissions() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    await MainActor.run {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                return granted
            } catch {
                statusMessage = error.localizedDescription
                return false
            }
        }

        if settings.authorizationStatus == .denied {
            statusMessage = "Enable notifications in iPhone Settings to receive alerts."
            return false
        }

        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
            return true
        }

        return false
    }

    func sendLocalNotification(title: String, message: String) async {
        notifications.insert(AppNotification(title: title, message: message), at: 0)
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                guard granted else {
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
        content.badge = NSNumber(value: max(1, notifications.count))

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "merluy-admin-\(UUID().uuidString)", content: content, trigger: trigger)

        do {
            try await center.add(request)
            statusMessage = "Notification scheduled for this iPhone."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func sendRemoteNotification(title: String, message: String) async {
        guard !serverURL.isEmpty, serverURL != "https://your-free-server.example.com" else {
            await sendLocalNotification(title: title, message: message)
            statusMessage = "Server URL not set yet. Local alert was sent instead."
            return
        }

        guard let url = URL(string: serverURL + "/api/notify") else {
            statusMessage = "Remote server URL is invalid."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RemoteNotificationRequest(
            title: title,
            message: message,
            platform: "ios",
            deviceToken: deviceToken,
            sound: "default"
        )

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode {
                statusMessage = "Notification sent to iPhone and Android devices."
            } else {
                statusMessage = "Remote server rejected the notification. Falling back to a local alert."
            }
            await sendLocalNotification(title: title, message: message)
        } catch {
            statusMessage = "Remote push failed: \(error.localizedDescription). Local alert is still available."
            await sendLocalNotification(title: title, message: message)
        }
    }

    func clearNotifications() {
        notifications.removeAll()
    }
}
