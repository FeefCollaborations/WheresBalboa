import UIKit
import FirebaseAuth
import PopupDialog
import KeychainAccess

class ProfileViewController: UIViewController, UISearchBarDelegate, LocationSearchTableViewControllerDelegate, AccountEditor, UITextFieldDelegate {
    @IBOutlet private var infoContainerView: UIView!
    @IBOutlet private var logoutBarButtonItem: UIBarButtonItem!
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var whatsappTextField: UITextField!
    @IBOutlet private var hometownButton: UIButton!
    @IBOutlet private var stackViewVerticalCenterConstraint: NSLayoutConstraint!
    
    private var updatedAddress: Address?
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "What city are you headed to?"
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    let keyboardManager = KeyboardManager()
    let userManager: UserManager
    
    // MARK: - Init
    
    init(_ userManager: UserManager) {
        self.userManager = userManager
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
        let user = userManager.loggedInUser
        nameTextField.text = user.metadata.name
        whatsappTextField.text = user.metadata.whatsapp
        hometownButton.setTitle(user.metadata.hometown.cityName, for: .normal)
        keyboardManager.onAnyChange = { [weak self] frame in
            guard let strongSelf = self else {
                return
            }
            
            // TODO: Figure out a better way to deal with view extending under top bars
            let overlapHeight = strongSelf.view.frame.intersection(frame).height
            let updatedConstraintValue = overlapHeight != 0 ? -(overlapHeight - 64) / 2 : 0
            if strongSelf.stackViewVerticalCenterConstraint.constant != updatedConstraintValue {
                strongSelf.stackViewVerticalCenterConstraint.constant = updatedConstraintValue
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Button response
    
    @IBAction private func logout() {
        Keychain.standard.setLoginInfo(nil)
        try? Auth.auth().signOut()
        navigationController?.popToLoginViewController()
    }
    
    @IBAction private func saveProfileChanges() {
        guard
            let name = nameTextField.text?.trimmingCharacters(in: [" "]),
            !name.isEmpty,
            let whatsapp = whatsappTextField.text?.trimmingCharacters(in: [" "]),
            !whatsapp.isEmpty
        else {
            showAlert(title: "Missing fields", message: "Please ensure that all fields are properly filled in")
            return
        }
        
        let hometown = updatedAddress ?? userManager.loggedInUser.metadata.hometown
        do {
            let metadata = try UserMetadata(name: name, whatsapp: whatsapp, hometown: hometown)
            let editOperation = UserEditOperation(metadata, userManager) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.dismiss(animated: true) {
                    switch result {
                        case .failure(let error):
                            strongSelf.showRetryAlert(message: error.localizedDescription, retryHandler: strongSelf.saveProfileChanges)
                        case .success:
                            strongSelf.showAlert(title: "Done!", message: "Successfully updated your information")
                    }
                }
            }
            showLoadingAlert()
            OperationQueue.main.addOperation(editOperation)
        } catch let error {
            showRetryAlert(message: error.localizedDescription, retryHandler: saveProfileChanges)
        }
        
    }
    
    @IBAction private func selectCity() {
        present(searchController, animated: true)
    }
    
    // MARK: - LocationSearchTableViewControllerDelegate
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, selectedAddress address: Address) {
        dismiss(animated: true)
        updatedAddress = address
        hometownButton.setTitle(address.cityName, for: .normal)
    }
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, encounteredError: Error?) {
        dismiss(animated: true) {
            self.showAlert()
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard
            let search = searchBar.text,
            search.isEmpty == false
        else {
            return
        }
        
        let searchTableViewController = LocationSearchTableViewController(search, delegate: self)
        let searchPopup = PopupDialog(viewController: searchTableViewController)
        searchController.present(searchPopup, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
