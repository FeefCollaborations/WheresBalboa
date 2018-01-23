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
        nameTextField.text = balbabe.metadata.name
        whatsappTextField.text = balbabe.metadata.whatsapp
        hometownButton.setTitle(balbabe.metadata.hometown.name, for: .normal)
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
        UserManager.shared.setCurrentUser(nil)
        Keychain.standard.setLoginInfo(nil)
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
        
        let hometown = updatedAddress ?? balbabe.metadata.hometown
        do {
            let metadata = try BalbabeMetadata(name: name, whatsapp: whatsapp, hometown: hometown)
            let editOperation = BalbabeEditOperation(balbabeMetadata: metadata, balbabeID: balbabe.id) { [weak self] result in
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
    
    @IBAction private func updateEmail() {
        let promptViewController = TextFieldPromptViewController.init(promptText: "Update to what email?", placeholderText: "Email") { inputText, onComplete in
            Auth.auth().currentUser!.updateEmail(to: inputText, completion: { error in
                onComplete(error?.localizedDescription ?? "Succesfully updated your email!")
            })
        }
        let alert = PopupDialog(viewController: promptViewController)
        present(alert, animated: true)
    }
    
    @IBAction private func updatePassword() {
        let promptViewController = TextFieldPromptViewController.init(promptText: "Where to send a password reset email?", placeholderText: "Email") { inputText, onComplete in
            Auth.auth().sendPasswordReset(withEmail: inputText, completion: { error in
                onComplete(error?.localizedDescription ?? "Sent! Check your email.")
            })
        }
        let alert = PopupDialog(viewController: promptViewController)
        present(alert, animated: true)
    }
    
    // MARK: - LocationSearchTableViewControllerDelegate
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, selectedAddress address: Address) {
        dismiss(animated: true)
        updatedAddress = address
        hometownButton.setTitle(address.name, for: .normal)
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
