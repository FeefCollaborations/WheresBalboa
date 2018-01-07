import UIKit

class LoadingView: UIView {
    private var state: LoadingViewState = .loading
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loadingIndicator.color = .black
        loadingIndicator.startAnimating()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        return loadingIndicator
    }()
    
    private lazy var loadingLabel: UILabel = {
        let loadingLabel = UILabel()
        loadingLabel.text = "Loading..."
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        return loadingLabel
    }()
    
    private lazy var loadingStackView: UIStackView = {
        let stackview = UIStackView.init(arrangedSubviews: [loadingIndicator, loadingLabel])
        stackview.backgroundColor = .red
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
    private lazy var failureLabel: UILabel = {
        let failureLabel = UILabel()
        failureLabel.numberOfLines = 0
        failureLabel.translatesAutoresizingMaskIntoConstraints = false
        return failureLabel
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    // MARK: - Subview management
    
    private func setupSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
        switch state {
            case .loading:
                self.addSubview(loadingStackView)
                loadingStackView.addCenterInParentConstraints()
            case .failed(let displayText):
                failureLabel.text = displayText
                self.addSubview(failureLabel)
                failureLabel.addCenterInParentConstraints()
        }
    }
    
    // MARK: - State management
    
    func update(to state: LoadingViewState) {
        guard self.state != state else {
            return
        }
        
        self.state = state
        setupSubviews()
    }
}
