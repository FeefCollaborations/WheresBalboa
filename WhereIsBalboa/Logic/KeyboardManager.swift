import UIKit

class KeyboardManager: NSObject {
    typealias KeyboardUpdateBlock = (CGRect) -> Void
    
    var onShow: KeyboardUpdateBlock?
    var onHide: KeyboardUpdateBlock?
    var onChangeFrame: KeyboardUpdateBlock?
    var onAnyChange: KeyboardUpdateBlock?
    
    init(onShow: KeyboardUpdateBlock? = nil, onHide: KeyboardUpdateBlock? = nil, onChangeFrame: KeyboardUpdateBlock? = nil, onAnyChange: KeyboardUpdateBlock? = nil) {
        self.onShow = onShow
        self.onHide = onHide
        self.onChangeFrame = onChangeFrame
        self.onAnyChange = onAnyChange
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(willShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Response
    
    @objc private func willShow(notification: Notification) {
        getFrame(from: notification, andCall: [onShow, onAnyChange])
    }
    
    @objc private func willHide(notification: Notification) {
        getFrame(from: notification, andCall: [onHide, onAnyChange])
    }
    
    @objc private func willChangeFrame(notification: Notification) {
        getFrame(from: notification, andCall: [onChangeFrame, onAnyChange])
    }
    
    // MARK: - Helpers
    
    private func getFrame(from notification: Notification, andCall methods: [KeyboardUpdateBlock?]) {
        guard
            let frame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curveValue = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let options = UIViewAnimationCurve(rawValue: curveValue)?.optionsValue
        else {
            return
        }
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            methods.forEach { $0?(frame) }
        })
    }
}
