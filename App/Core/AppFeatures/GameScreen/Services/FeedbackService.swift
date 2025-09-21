// App/Core/AppFeatures/GameScreen/Services/FeedbackService.swift

import UIKit

final class FeedbackService {
    
    private let selectionHaptic = UISelectionFeedbackGenerator()
    private let notificationHaptic = UINotificationFeedbackGenerator()

    init() {
        selectionHaptic.prepare()
        notificationHaptic.prepare()
    }

    func selectionChanged() {
        selectionHaptic.selectionChanged()
    }

    func notify(evaluation: SetEvalStatus) {
        guard evaluation != .none else { return }
        let type: UINotificationFeedbackGenerator.FeedbackType = (evaluation == .found) ? .success : .error
        notificationHaptic.notificationOccurred(type)
    }
}
