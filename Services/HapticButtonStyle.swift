import SwiftUI

struct HapticButtonStyle: ButtonStyle {
    @State private var isPressed = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .gesture(
                LongPressGesture(minimumDuration: 0, maximumDistance: 50)
                    .onChanged { _ in
                        isPressed = true
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                    .onEnded { _ in
                        isPressed = false
                        configuration.trigger()
                    }
            )
    }
}
