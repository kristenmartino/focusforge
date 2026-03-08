import UserNotifications
import Observation

@Observable
final class NotificationService {
    private let center = UNUserNotificationCenter.current()
    private let timerNotificationID = "focusforge.timer.completion"

    private(set) var isAuthorized: Bool = false

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func checkCurrentStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleCompletion(in seconds: TimeInterval, sessionType: SessionPhase) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        switch sessionType {
        case .focus:
            content.title = "Focus Complete!"
            content.body = "Great work! Time for a break."
        case .shortBreak:
            content.title = "Break's Over!"
            content.body = "Ready to focus again?"
        case .longBreak:
            content.title = "Long Break's Over!"
            content.body = "Feeling refreshed? Let's go."
        }
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, seconds),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: timerNotificationID,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelPending() {
        center.removePendingNotificationRequests(withIdentifiers: [timerNotificationID])
    }
}
