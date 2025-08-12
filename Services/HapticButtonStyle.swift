import SwiftUI

struct HapticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .sensoryFeedback(.impact(weight: .heavy, intensity: 1.0), trigger: configuration.isPressed)
    }
}
