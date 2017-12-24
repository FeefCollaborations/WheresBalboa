import UIKit

class OwnTripTableViewCell: UITableViewCell {
    static let nib = UINib(nibName: "OwnTripTableViewCell", bundle: nil)
    
    @IBOutlet private(set) var cityLabel: UILabel!
    @IBOutlet private(set) var dateLabel: UILabel!
}

