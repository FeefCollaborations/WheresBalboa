import UIKit

extension UIToolbar {
    static func new(withTarget target: Any, andSelector selector: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .done, target: target, action: selector)], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }
}
