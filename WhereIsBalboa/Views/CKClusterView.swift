import MapKit
import UIKit

class CKClusterView: MKAnnotationView {
    lazy var title: UILabel = {
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.systemFont(ofSize: 10)
        label.frame = bounds
        label.textAlignment = .center
        label.textColor = .white
        addSubview(label)
        return label
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.darkGray
        frame = CGRect(origin: frame.origin, size: CGSize(width: 30.0, height: 30.0))
        layer.cornerRadius = bounds.size.width * 0.5
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 3.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateBorderColor(to borderColor: UIColor) {
        layer.borderColor = borderColor.cgColor
    }
}
