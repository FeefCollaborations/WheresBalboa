import UIKit
import PopupDialog

class TripEditorViewController: UIViewController, UITextFieldDelegate, LocationSearchTableViewControllerDelegate, UISearchBarDelegate {
    @IBOutlet private var cityButton: UIButton!
    @IBOutlet private var startDateTextField: UITextField!
    @IBOutlet private var endDateTextField: UITextField!
    
    @IBOutlet private var deleteButton: UIButton!
    
    private var builder = TripEditOperation.Builder()
    let trip: Trip?
    private let userManager: UserManager
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "What city are you headed to?"
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.timeZone = .current
        datePicker.datePickerMode = .date
        return datePicker
    }()
    private let doneToolbar: UIToolbar = {
        return UIToolbar.newDoneToolbar(withTarget: self, andSelector: #selector(doneTappedOnDateToolbar))
    }()
    private let dateFormatter = DateFormatter.fullDateShortenedYear
    
    // MARK: - Init
    
    init(_ userManager: UserManager, _ trip: Trip? = nil) {
        self.trip = trip
        self.userManager = userManager
        super.init(nibName: nil, bundle: nil)
        builder.userManager = userManager
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
        
        startDateTextField.inputView = datePicker
        endDateTextField.inputView = datePicker
        startDateTextField.inputAccessoryView = doneToolbar
        endDateTextField.inputAccessoryView = doneToolbar
        
        guard let trip = trip else {
            deleteButton.isHidden = true
            return
        }
        
        builder.tripID = trip.id
        builder.address = trip.metadata.address
        let startDate = trip.metadata.dateInterval.start
        let endDate = trip.metadata.dateInterval.end
        builder.startDate = startDate
        builder.endDate = endDate
        
        cityButton.setTitle(trip.metadata.address.cityName, for: .normal)
        startDateTextField.text = dateFormatter.string(from: startDate)
        endDateTextField.text = dateFormatter.string(from: endDate)
    }
    
    // MARK: - LocationSearchTableViewControllerDelegate
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, selectedAddress address: Address) {
        dismiss(animated: true)
        builder.address = address
        cityButton.setTitle(address.cityName, for: .normal)
    }
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, encounteredError: Error?) {
        dismiss(animated: true) {
            self.showAlert()
        }
    }
    
    // MARK: - Button response
    
    @IBAction private func saveTrip() {
        let tripEditOperation = builder.build() { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            let afterDismiss = {
                switch result {
                    case .success:
                        let successMessage = strongSelf.trip != nil ? "Trip updated!" : "Trip Created!"
                        strongSelf.showOneOptionAlert(title: "Success!", message: successMessage) {
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                    case .failure:
                        // TODO: Log error
                        let failureMessage = strongSelf.trip != nil ? "Unable to update your trip" : "Unable to create your trip"
                        strongSelf.showRetryAlert(message: failureMessage, retryHandler: strongSelf.saveTrip)
                        return
                }
            }
            strongSelf.dismiss(animated: true, completion: afterDismiss)
        }
        
        guard let editOperation = tripEditOperation else {
            showOneOptionAlert(title: "Failed!", message: "Please ensure all fields are filled in")
            return
        }
        
        showLoadingAlert()
        OperationQueue.main.addOperation(editOperation)
    }
    
    @IBAction private func deleteTrip() {
        guard let tripID = trip?.id else {
            return
        }
        
        let confirmButton = DestructiveButton(title: "Yes") { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let deleteTripOperation = TripDeleteOperation(strongSelf.userManager.cohort, tripID) { result in
                strongSelf.dismiss(animated: true) {
                    switch result {
                    case .success:
                        strongSelf.showOneOptionAlert(title: "Poof!", message: "Deleted your trip") {
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                    case .failure:
                        strongSelf.showRetryAlert(message: "Something went wrong, please try again", retryHandler: strongSelf.deleteTrip)
                    }
                }
            }
            strongSelf.showLoadingAlert()
            OperationQueue.main.addOperation(deleteTripOperation)
        }
        let cancelButton = CancelButton(title: "Cancel") {}
        showAlert(title: "Are you sure?", message: "This will completely delete the trip from your profile. Are you sure you want to do this?", buttons: [confirmButton, cancelButton])
    }
    
    @IBAction private func selectCity() {
        present(searchController, animated: true)
    }
    
    @objc private func doneTappedOnDateToolbar() {
        let activeTextField: UITextField = startDateTextField.isFirstResponder ? startDateTextField : endDateTextField
        activeTextField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == startDateTextField {
            datePicker.minimumDate = nil
            if
                let dateText = startDateTextField.text,
                let date = dateFormatter.date(from: dateText)
            {
                datePicker.date = date
            }
        } else if textField == endDateTextField {
            if let startDate = builder.startDate {
                datePicker.minimumDate = startDate
            }
            if
                let dateText = endDateTextField.text,
                let date = dateFormatter.date(from: dateText)
            {
                datePicker.date = date
            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let selectedDate = datePicker.date.startOfDay()
        let endDate = selectedDate.endOfDay() - 1
        let isStart = startDateTextField == textField
        if isStart {
            builder.startDate = selectedDate
            if
                let endDateText = endDateTextField.text,
                let currentEndDate = dateFormatter.date(from: endDateText),
                selectedDate.compare(currentEndDate) == ComparisonResult.orderedDescending
            {
                builder.endDate = endDate
                endDateTextField.text = dateFormatter.string(from: selectedDate)
            }
        } else {
            builder.endDate = endDate
        }
        textField.text = dateFormatter.string(from: selectedDate)
        return true
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
}
