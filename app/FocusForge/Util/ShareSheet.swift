import SwiftUI
import UIKit

/// Thin UIViewControllerRepresentable wrapper around UIActivityViewController so
/// SwiftUI views can present the system share sheet. SwiftUI's ShareLink covers
/// most cases, but for sharing a file URL that's generated on-tap (rather than
/// existing as a static property at render time) it's cleaner to drive the share
/// sheet imperatively from a Button action.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        // Exclude activities that don't make sense for a JSON backup.
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .postToVimeo,
            .postToTencentWeibo,
            .postToFlickr,
            .saveToCameraRoll,
        ]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
