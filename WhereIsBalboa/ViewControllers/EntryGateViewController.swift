import UIKit
import FirebaseAuth

class EntryGateViewController: UIViewController {
    
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Button response
    
    @IBAction private func signIn() {
        // TODO: Validate legit user credentials
        let homeViewController = HomeViewController(Balbabe.dummy())
        navigationController?.pushViewController(homeViewController, animated: true)
    }
}
