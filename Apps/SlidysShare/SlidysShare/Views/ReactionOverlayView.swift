import SwiftUI
import SlidysShareCore

struct ReactionOverlayView: View {
    let reactions: [ReceivedReaction]
    var onRemove: (UUID) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(reactions.suffix(20))) { reaction in
                    ReactionBubbleView(reaction: reaction, containerSize: geometry.size, onRemove: onRemove)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#if DEBUG
#Preview {
    ReactionOverlayView(reactions: PreviewSampleData.sampleReactions) { _ in }
}
#endif

private struct ReactionBubbleView: View {
    let reaction: ReceivedReaction
    let containerSize: CGSize
    var onRemove: (UUID) -> Void

    @State private var isAnimating = false

    private var horizontalPosition: CGFloat {
        // Deterministic position based on UUID
        let hash = reaction.id.hashValue
        let normalized = CGFloat(Int(bitPattern: UInt(bitPattern: hash) % 1000)) / 1000.0
        let margin: CGFloat = 60
        return margin + normalized * (containerSize.width - margin * 2)
    }

    var body: some View {
        Text(reaction.type.emoji)
            .font(.system(size: 40))
            .position(
                x: horizontalPosition,
                y: isAnimating ? containerSize.height * 0.2 : containerSize.height - 40
            )
            .opacity(isAnimating ? 0 : 1)
            .scaleEffect(isAnimating ? 1.2 : 0.6)
            .onAppear {
                withAnimation(.easeOut(duration: 2.5)) {
                    isAnimating = true
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(2.5))
                    guard !Task.isCancelled else { return }
                    onRemove(reaction.id)
                }
            }
    }
}
