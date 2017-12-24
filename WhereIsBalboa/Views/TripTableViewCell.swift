import UIKit

class TripTableViewCell: UITableViewCell {
    static let nib = UINib(nibName: "TripTableViewCell", bundle: nil)
    
    @IBOutlet private(set) var nameLabel: UILabel!
    @IBOutlet private(set) var cityLabel: UILabel!
    @IBOutlet private(set) var dateLabel: UILabel!
    @IBOutlet private(set) var distanceLabel: UILabel!
    @IBOutlet private(set) var locationImageView: UIImageView!
    
    var onContactTapped: ((TripTableViewCell) -> Void)? = nil
    
    // MARK: - Button response
    
    @IBAction private func tappedContact() {
        onContactTapped?(self)
    }
}
