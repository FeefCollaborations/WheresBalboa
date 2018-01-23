import UIKit

extension UINavigationController {
    func popToLoginViewController(animated: Bool = true) {
        guard let loginViewController = viewControllers.first(where: { $0 is LoginViewController }) else {
            return
        }
        popToViewController(loginViewController, animated: animated)
    }
}
