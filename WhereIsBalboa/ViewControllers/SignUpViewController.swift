import UIKit
import PopupDialog

class SignUpViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate, LocationSearchTableViewControllerDelegate {
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var whatsappTextField: UITextField!
    @IBOutlet private var hometownButton: UIButton!
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Where are ya from?"
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private var builder = BalbabeCreateOperation.Builder()
    
    // MARK: - Init
    
    init(email: String, password: String) {
        super.init(nibName: nil, bundle: nil)
        builder.email = email
        builder.password = password
        guard #available(iOS 11.0, *) else {
            edgesForExtendedLayout = []
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        let searchTableViewController = LocationSearchTableViewController.init(search, delegate: self)
        let searchPopup = PopupDialog.init(viewController: searchTableViewController)
        searchController.present(searchPopup, animated: true)
    }
    
    // MARK: - Button response
    
    @IBAction private func tappedAddHometown() {
        present(searchController, animated: true)
    }
    
    @IBAction private func tappedCreate() {
        builder.name = nameTextField.text
        builder.whatsapp = whatsappTextField.text
        createBalbabe()
    }
    
    private func createBalbabe() {
        do {
            let createOperation = try builder.build { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.dismiss(animated: true) {
                        switch result {
                            case .failure:
                                strongSelf.showRetryAlert(message: "We encountered an error. Please try again.", retryHandler: strongSelf.createBalbabe)
                            case .success(let balbabe):
                                let okButton = DefaultButton.init(title: "YAY!!") {
                                    UserManager.shared.setCurrentUser(balbabe)
                                    let homeViewController = HomeViewController(balbabe)
                                    strongSelf.navigationController?.pushViewController(homeViewController, animated: true)
                                }
                                strongSelf.showAlert(title: "Success!", message: "Welcome to the app :)", buttons: [okButton])
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
}
