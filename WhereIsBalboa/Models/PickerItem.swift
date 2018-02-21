import UIKit

struct PickerItem {
    let value: String
    init(_ string: String) {
        self.value = string
    }
    
    func generateView() -> UIView {
        return UILabel()
    }
}
