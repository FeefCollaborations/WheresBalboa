import UIKit
import PopupDialog

class TripEditorViewController: UIViewController, UITextFieldDelegate, LocationSearchTableViewControllerDelegate, UISearchBarDelegate {
    @IBOutlet private var cityButton: UIButton!
    @IBOutlet private var startDateTextField: UITextField!
    @IBOutlet private var endDateTextField: UITextField!
    
    @IBOutlet private var deleteButton: UIButton!
    
    private var builder = TripEditOperation.Builder()
    let trip: Trip?
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "What city are you headed to?"
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    private let doneToolbar: UIToolbar = {
        return UIToolbar.new(withTarget: self, andSelector: #selector(doneTappedOnDateToolbar))
    }()
    private let dateFormatter = DateFormatter.fullDate
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe, _ trip: Trip? = nil) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
        builder.balbabe = balbabe
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
        builder.startDate = trip.metadata.dateInterval.start
        builder.endDate = trip.metadata.dateInterval.end
        
        cityButton.setTitle(trip.metadata.address.name, for: .normal)
        startDateTextField.text = DateFormatter.fullDate.string(from: trip.metadata.dateInterval.start)
        endDateTextField.text = DateFormatter.fullDate.string(from: trip.metadata.dateInterval.end)
    }
    
    // MARK: - LocationSearchTableViewControllerDelegate
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, selectedAddress address: Address) {
        dismiss(animated: true)
        builder.address = address
        cityButton.setTitle(address.name, for: .normal)
    }
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, encounteredError: Error?) {
        dismiss(animated: true) {
            self.showAlert()
        }
    }
    
    // MARK: - Button response
    
    @IBAction private func saveTrip() {
        guard
            let startDate = builder.startDate,
            let endDate = builder.endDate
        else {
            showOneOptionAlert(title: "Failed!", message: "Please ensure all fields are filled in")
            return
        }
        
        let interval = DateInterval(start: startDate, end: endDate)
        let overlappingTrip = builder.balbabe?.trips.first(where: { $0.metadata.dateInterval.intersects(interval) && builder.tripID != $0.id })
        guard overlappingTrip == nil else {
            showOneOptionAlert(title: "Failed!", message: "This trip overlaps with one of your other trips. Please edit the other one first.")
            return
        }
        
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
        guard
            let trip = trip,
            let balbabe = builder.balbabe
        else {
            return
        }
        
        let deleteTripOperation = TripDeleteOperation(tripID: trip.id, balbabeID: balbabe.id) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
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
        showLoadingAlert()
        OperationQueue.main.addOperation(deleteTripOperation)
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
            datePicker.minimumDate = Date()
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
        let selectedDate = datePicker.date
        if startDateTextField == textField {
            builder.startDate = selectedDate + 1000
            if
                let endDateText = endDateTextField.text,
                let currentEndDate = dateFormatter.date(from: endDateText),
                selectedDate.compare(currentEndDate) == ComparisonResult.orderedDescending
            {
                builder.endDate = selectedDate
                endDateTextField.text = dateFormatter.string(from: selectedDate)
            }
        } else {
            builder.endDate = selectedDate
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
