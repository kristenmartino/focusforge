import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Timer") {
                    Text("Focus duration")
                    Text("Short break duration")
                    Text("Long break duration")
                }
                Section("Notifications") {
                    Text("Timer completion alerts")
                }
                Section("About") {
                    Text("Version 0.1.0")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
