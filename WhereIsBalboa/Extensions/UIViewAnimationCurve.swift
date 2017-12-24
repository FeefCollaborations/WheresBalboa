import UIKit

extension UIViewAnimationCurve {
    var optionsValue: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(rawValue << 16))
    }
}
