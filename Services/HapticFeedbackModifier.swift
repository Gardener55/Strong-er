import SwiftUI

/// A view modifier that adds haptic feedback to a view on tap.
///
/// Note: This modifier should not be used on `Button` views, as it will
/// override the button's action. For buttons, use `HapticButtonStyle` instead.
struct HapticFeedbackOnTap: ViewModifier {
    var style: SensoryFeedback.FeedbackStyle
    @State private var isTapped: Bool = false

    init(style: SensoryFeedback.FeedbackStyle = .impact) {
        self.style = style
    }

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                isTapped.toggle()
            }
            .sensoryFeedback(style, trigger: isTapped)
    }
}

extension View {
    /// Adds haptic feedback to a view on tap.
    ///
    /// Note: This modifier should not be used on `Button` views, as it will
    /// override the button's action. For buttons, use `HapticButtonStyle` instead.
    func withHapticFeedback(style: SensoryFeedback.FeedbackStyle = .impact) -> some View {
        self.modifier(HapticFeedbackOnTap(style: style))
    }
}
