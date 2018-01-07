import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet private var logoutBarButtonItem: UIBarButtonItem!
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var whatsappTextField: UITextField!
    @IBOutlet private var hometownTextField: UITextField!
    @IBOutlet private var newPasswordTextField: UITextField!
    @IBOutlet private var confirmPasswordTextField: UITextField!
        
    let balbabe: Balbabe
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe) {
        self.balbabe = balbabe
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
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = logoutBarButtonItem
        nameTextField.text = balbabe.name
        whatsappTextField.text = balbabe.whatsapp
        hometownTextField.text = balbabe.hometown.city + ", " + balbabe.hometown.country
    }
    
    // MARK: - Button response
    
    @IBAction private func logout() {
        //TODO: Sign out of current user
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func saveProfileChanges() {
        // TODO: Send off profile changes to FireBase
    }
}
