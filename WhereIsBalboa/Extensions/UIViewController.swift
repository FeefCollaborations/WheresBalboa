import UIKit
import PopupDialog

extension UIViewController {
    static private func okButton(_ handler: (() -> Void)? = nil) -> PopupDialogButton {
        return DefaultButton(title: "OK", action: handler)
    }
    
    private var topMostViewController: UIViewController {
        return navigationController?.topViewController ?? (presentedViewController ?? self)
    }
    
    func showOneOptionAlert(title: String? = nil, message: String? = "Something went wrong, please try again", action: (() -> Void)? = nil) {
        showAlert(title: title, message: message, buttons: [UIViewController.okButton(action)])
    }
    
    func showAlert(title: String? = nil, message: String? = "Something went wrong, please try again", buttons: [PopupDialogButton] = [okButton()]) {
        let alignment: UILayoutConstraintAxis = buttons.count < 3 ? .horizontal : .vertical
        let popup = PopupDialog(title: title, message: message, buttonAlignment: alignment)
        popup.addButtons(buttons)
        topMostViewController.present(popup, animated: true)
    }
    
    func showLoadingAlert(_ title: String = "Loading") {
        showAlert(title: title, message: nil, buttons: [])
    }
    
    func showRetryAlert(title: String = "We encountered an error", message: String, retryHandler: @escaping (() -> Void), cancelHandler: (() -> Void)? = nil) {
        var buttons: [PopupDialogButton] = [DefaultButton(title: "Retry", action: retryHandler)]
        if let cancelHandler = cancelHandler {
            buttons.append(CancelButton(title: "Cancel", action: cancelHandler))
        }
        showAlert(title: title, message: message, buttons: buttons)
    }
}
