import SwiftUI

public struct AsyncButton<Label: View>: View {
    var action: @MainActor () async -> Void
    var label: Label
    var isInProgress: Bool { taskInProgress != nil }
    @State var taskInProgress: Task<Void, Never>?

    public init(action: @MainActor @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button {
            taskInProgress?.cancel()
            taskInProgress = Task { await action() }
        } label: {
            ZStack {
                label.opacity(isInProgress ? 0 : 1)

                if isInProgress {
                    ProgressView().controlSize(.regular)
                }
            }
        }
        .disabled(isInProgress)
        .onDisappear {
            taskInProgress?.cancel()
            taskInProgress = nil
        }
        .task(id: taskInProgress) {
            await taskInProgress?.value
            taskInProgress = nil
        }
    }
}

extension AsyncButton where Label == Text {
    public init(_ label: String, action: @escaping () async -> Void) {
        self.init(action: action) {
            Text(label)
        }
    }
}

extension AsyncButton where Label == Image {
    public init(systemImageName: String, action: @escaping () async -> Void) {
        self.init(action: action) {
            Image(systemName: systemImageName)
        }
    }
}
