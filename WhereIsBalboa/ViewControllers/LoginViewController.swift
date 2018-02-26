import UIKit
import FirebaseAuth
import PopupDialog
import KeychainAccess

class LoginViewController: UIViewController, UITextFieldDelegate, AccountEditor {
    @IBOutlet private var passcodeTextField: UITextField!
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        guard #available(iOS 11.0, *) else {
            edgesForExtendedLayout = []
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        passcodeTextField.text = nil
    }
    
    // MARK: - Button response
    
    @IBAction private func tappedLoginOrSignUp() {
        passcodeTextField.resignFirstResponder()
        
        guard let passcode = passcodeTextField.text else {
            return
        }
        
        let loginOperation = LoginOperation(passcode) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
                case .success(let user, let cohort):
                    let loginInfo = LoginInfo(signUpCode: passcode, cohort: cohort)
                    Keychain.standard.setLoginInfo(loginInfo)
                    UserManager.new(for: loginInfo.cohort, withLoggedInUser: user) { result in
                        DispatchQueue.main.async {
                            strongSelf.dismiss(animated: true) {
                                switch result {
                                    case .failure:
                                        strongSelf.showAlert()
                                        return
                                    case .success(let userManager):
                                        let homeViewController = HomeViewController(userManager)
                                        strongSelf.navigationController?.pushViewController(homeViewController, animated: true)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        strongSelf.dismiss(animated: true) {
                            if
                                let error = error,
                                case let LoginOperation.LoginError.userMustCreateAccount(userProxy) = error
                            {
                                
                                let signUpViewController = SignUpViewController(userProxy, passcode: passcode)
                                strongSelf.navigationController?.pushViewController(signUpViewController, animated: true)
                            } else {
                                strongSelf.showOneOptionAlert(title: "Failure", message: "We couldn't find the user for that code. Please ensure you've entered it correctly.")
                            }
                        }
                    }
            }
        }
        showLoadingAlert()
        OperationQueue.main.addOperation(loginOperation)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
