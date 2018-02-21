import UIKit

class PickerViewWrapper: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: .zero)
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    let items: [PickerItem]
    private(set) var currentlySelectedItem: PickerItem
    
    // MARK: - Initialization
    
    init?(_ items: [PickerItem], currentlySelectedIndex: Int = 0) {
        guard currentlySelectedIndex < items.count else {
            return nil
        }
        
        self.items = items
        currentlySelectedItem = items[currentlySelectedIndex]
        super.init()
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let currentItem = items[row]
        let updatedView: UIView
        if let view = view {
            updatedView = view
        } else {
            updatedView = currentItem.generateView()
        }
        populate(updatedView, with: currentItem)
        return updatedView
    }
    
    // MARK: - Population
    
    private func populate(_ view: UIView, with item: PickerItem) {
        guard let label = view as? UILabel else {
            // TODO: Log error
            return
        }
        label.text = item.value
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentlySelectedItem = items[row]
    }
}
