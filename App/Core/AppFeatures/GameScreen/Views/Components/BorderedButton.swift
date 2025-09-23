// App/Core/AppFeatures/GameScreen/Views/Components/BorderedButtonView.swift

import UIKit

enum ButtonFactory {
    
    static func createBorderedButton(title: String, target: Any, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.bordered()
        configuration.title = title
        button.configuration = configuration
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
}
