import UIKit

extension UIView {
    func addFitToParentContraints(with insets: UIEdgeInsets = .zero) {
        guard let superview = superview else {
            return
        }
        
        topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
    }
    
    func addCenterInParentConstraints(with insets: UIEdgeInsets = .zero) {
        guard let superview = superview else {
            return
        }
        
        centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        
        topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor, constant: insets.top).isActive = true
        leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(greaterThanOrEqualTo: superview.trailingAnchor, constant: -insets.right).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
    }
    
    // https://gist.github.com/nazywamsiepawel/0166e8a71d74e96c7898
    static func viewControllerTitleView(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-5, width:0, height:0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.black
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff > 0 {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = frame.integral
        } else {
            var frame = subtitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            titleLabel.frame = frame.integral
        }
        
        return titleView
    }
}
