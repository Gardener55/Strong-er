import SwiftUI

struct HapticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .sensoryFeedback(.impact, trigger: configuration.isPressed)
    }
}
