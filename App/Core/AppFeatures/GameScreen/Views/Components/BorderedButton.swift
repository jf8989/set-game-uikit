// App/Core/AppFeatures/GameScreen/Views/Components/BorderedButton.swift

import UIKit

final class BorderedButton: UIButton {
    convenience init(title: String) {
        self.init(type: .system)
        var config = UIButton.Configuration.bordered()
        config.title = title
        self.configuration = config
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
