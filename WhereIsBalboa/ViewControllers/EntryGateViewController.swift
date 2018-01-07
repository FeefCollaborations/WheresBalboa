import UIKit
import FirebaseAuth
import CoreLocation

class EntryGateViewController: UIViewController {
    
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    
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
    
    // MARK: - Button response
    
    @IBAction private func signIn() {
        // TODO: Validate legit user credentials
        let hometown = Address(location: CLLocation.init(latitude: 6.2, longitude: -75.5), city: "medellin", state: "antioquia", country: "Colombia")
        let homeViewController = HomeViewController(Balbabe.dummy("feef", hometown))
        navigationController?.pushViewController(homeViewController, animated: true)
    }
}
