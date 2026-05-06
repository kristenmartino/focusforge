import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

/// Firebase-backed implementation of the AnalyticsBackend protocol.
///
/// Forwards every event into Firebase Analytics with parameters intact,
/// and mirrors a copy into Crashlytics as a custom log so the most recent
/// events appear in any crash report. User properties go to both Analytics
/// (for segmentation) and Crashlytics (for crash filtering).
struct FirebaseAnalyticsBackend: AnalyticsBackend {
    init() {
        // Override the plist's IS_ANALYTICS_ENABLED=false default so events
        // actually flow even if the project was created with Analytics
        // disabled at the wizard step.
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    func track(event: String, parameters: [String: Any]) {
        Analytics.logEvent(event, parameters: parameters)
        Crashlytics.crashlytics().log("\(event) \(parameters)")
        #if DEBUG
        if parameters.isEmpty {
            print("[Analytics] \(event)")
        } else {
            print("[Analytics] \(event) \(parameters)")
        }
        #endif
    }

    func setUserProperty(_ value: String?, forKey key: String) {
        Analytics.setUserProperty(value, forName: key)
        if let value {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
        #if DEBUG
        print("[Analytics] userProperty \(key)=\(value ?? "nil")")
        #endif
    }
}
