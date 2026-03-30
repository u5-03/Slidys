import SwiftUI
import SlidysShareCore

struct ReactionPickerView: View {
    var onReaction: (ReactionType) -> Void

    @State private var lastSentDate: Date = .distantPast
    @State private var tappedType: ReactionType?

    var body: some View {
        HStack(spacing: 16) {
            ForEach(ReactionType.allCases, id: \.self) { type in
                Button {
                    sendReaction(type)
                } label: {
                    Text(type.emoji)
                        .font(.system(size: 28))
                        .scaleEffect(tappedType == type ? 1.3 : 1.0)
                        .animation(.spring(duration: 0.2), value: tappedType)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func sendReaction(_ type: ReactionType) {
        let now = Date()
        guard now.timeIntervalSince(lastSentDate) >= 1.0 else { return }
        lastSentDate = now
        tappedType = type
        onReaction(type)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.2))
            tappedType = nil
        }
    }
}

#if DEBUG
#Preview {
    ReactionPickerView { _ in }
}
#endif
