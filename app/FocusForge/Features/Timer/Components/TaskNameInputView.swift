import SwiftUI

struct TaskNameInputView: View {
    @Binding var taskName: String

    var body: some View {
        TextField("What are you working on?", text: $taskName)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 40)
            .submitLabel(.done)
            .accessibilityLabel("Task name, optional")
    }
}
