import UIKit
import PopupDialog
import KeychainAccess

class SignUpViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate, LocationSearchTableViewControllerDelegate {
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var whatsappTextField: UITextField!
    @IBOutlet private var hometownButton: UIButton!
    @IBOutlet private var cohortTextField: UITextField!
    
    let cohortPicker: PickerViewWrapper
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Where are ya from?"
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private let foundCohort: Cohort?
    private var builder = UserCreateOperation.Builder()
    
    // MARK: - Init
    
    init(_ userProxy: UserProxy, passcode: String) {
        let foundCohort = userProxy.cohort
        let selectedIndex: Int
        let cohorts = Cohort.all.map { PickerItem($0.rawValue) }
        if let cohort = foundCohort {
            selectedIndex = cohorts.index { $0.value == cohort.rawValue } ?? 0
        } else {
            selectedIndex = 0
        }
        self.foundCohort = foundCohort
        cohortPicker = PickerViewWrapper(cohorts, currentlySelectedIndex: selectedIndex)!
        super.init(nibName: nil, bundle: nil)
        builder.userID = passcode
        builder.cohort = userProxy.cohort
        builder.name = userProxy.name
        guard #available(iOS 11.0, *) else {
            edgesForExtendedLayout = []
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = builder.name
        if foundCohort == nil {
            cohortTextField.text = cohortPicker.currentlySelectedItem.value
            cohortTextField.inputView = cohortPicker.pickerView
            cohortTextField.inputAccessoryView = UIToolbar.newDoneToolbar(withTarget: self, andSelector: #selector(tappedDoneOnCohortPicker))
        } else {
            cohortTextField.isHidden = true
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - LocationSearchTableViewControllerDelegate
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, selectedAddress address: Address) {
        dismiss(animated: true)
        builder.hometown = address
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
        
        let searchTableViewController = LocationSearchTableViewController.init(search, delegate: self)
        let searchPopup = PopupDialog.init(viewController: searchTableViewController)
        searchController.present(searchPopup, animated: true)
    }
    
    // MARK: - Button response
    
    @objc private func tappedDoneOnCohortPicker() {
        cohortTextField.text = cohortPicker.currentlySelectedItem.value
        cohortTextField.resignFirstResponder()
    }
    
    @IBAction private func tappedAddHometown() {
        present(searchController, animated: true)
    }
    
    @IBAction private func tappedCreate() {
        builder.name = nameTextField.text
        builder.whatsapp = whatsappTextField.text
        createUser()
    }
    
    private func createUser() {
        do {
            let createOperation = try builder.build { [weak self, builder] result in
                guard
                    let strongSelf = self,
                    let cohort = builder.cohort
                else {
                    return
                }
                
                switch result {
                    case .failure:
                        DispatchQueue.main.async {
                            strongSelf.dismiss(animated: true) {
                                strongSelf.showRetryAlert(message: "We encountered an error. Please try again.", retryHandler: strongSelf.createUser)
                            }
                        }
                    case .success(let user):
                        UserManager.new(for: cohort, withLoggedInUser: user) { result in
                            switch result {
                                case .failure:
                                    DispatchQueue.main.async {
                                        strongSelf.dismiss(animated: true) {
                                            // TODO: Log error
                                            strongSelf.showOneOptionAlert(title: "Error", message: "We encountered an unexpected error. Please try to login a little later.", action: {
                                                strongSelf.navigationController?.popToRootViewController(animated: true)
                                            })
                                        }
                                    }
                                case .success(let userManager):
                                    strongSelf.addDefaultTrips(using: userManager)
                            }
                        }
                    }
                }
            showLoadingAlert()
            OperationQueue.main.addOperation(createOperation)
        } catch let error {
            showAlert(message: error.localizedDescription)
        }
    }
    
    private func addDefaultTrips(using userManager: UserManager) {
        let tripGroupOperation = TripGroupCreateOperation.init(userManager, userManager.cohort.tripMetadatas) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.dismiss(animated: true) {
                    switch result {
                        case .success:
                            let loginInfo = LoginInfo(signUpCode: userManager.loggedInUser.id, cohort: userManager.cohort)
                            Keychain.standard.setLoginInfo(loginInfo)
                            let okButton = DefaultButton(title: "YAY!!") {
                                let homeViewController = HomeViewController(userManager)
                                strongSelf.navigationController?.pushViewController(homeViewController, animated: true)
                            }
                            strongSelf.showAlert(title: "Success!", message: "Welcome to the app :)", buttons: [okButton])
                        case .failure:
                            // TODO: Log error
                            strongSelf.showRetryAlert(message: "We encountered an error. Please try again.", retryHandler: {
                                strongSelf.addDefaultTrips(using: userManager)
                            })
                    }
                }
            }
        }
        OperationQueue.main.addOperation(tripGroupOperation)
    }
}
