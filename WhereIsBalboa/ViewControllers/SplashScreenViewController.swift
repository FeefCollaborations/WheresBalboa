import UIKit
import KeychainAccess

class SplashScreenViewController: UIViewController {
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let loginInfo = Keychain.standard.getLoginInfo() else {
            showLoginViewController(animated: false)
            return
        }
        attemptLogin(with: loginInfo)
    }
    
    // MARK: - Helpers
    
    private func attemptLogin(with loginInfo: LoginInfo) {
        let operation = LoginOperation(loginInfo) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                    case .failure:
                        strongSelf.showLoginViewController()
                    case .success(let user):
                        UserManager.new(for: loginInfo.cohort, withLoggedInUser: user) { [weak self] result in
                            switch result {
                                case .success(let userManager):
                                    let homeViewController = HomeViewController(userManager)
                                    self?.navigationController?.setViewControllers([LoginViewController(), homeViewController], animated: true)
                                case .failure:
                                    self?.showLoginViewController()
                                    return
                            }
                        }
                }
            }
        }
        loadingIndicator.startAnimating()
        OperationQueue.main.addOperation(operation)
    }
    
    private func showLoginViewController(animated: Bool = true) {
        navigationController?.pushViewController(LoginViewController(), animated: animated)
    }
}
