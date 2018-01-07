import UIKit
import PopupDialog

class TripEditorTableViewController: UIViewController, UITextFieldDelegate, LocationSearchTableViewControllerDelegate {
    @IBOutlet private var cityTextField: UITextField!
    @IBOutlet private var startDateTextField: UITextField!
    @IBOutlet private var endDateTextField: UITextField!
    
    @IBOutlet private var deleteButton: UIButton!
    
    private var builder = TripEditOperation.Builder()
    let balbabe: Balbabe
    let trip: Trip?
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe, _ trip: Trip? = nil) {
        self.balbabe = balbabe
        self.trip = trip
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
        cityTextField.delegate = self
        guard let trip = trip else {
            deleteButton.isHidden = true
            return
        }
        
        builder.tripID = trip.id
        builder.address = trip.metadata.address
        builder.dateInterval = trip.metadata.dateInterval
        
        cityTextField.text = "\(trip.metadata.address.city), \(trip.metadata.address.country)"
        startDateTextField.text = DateFormatter.fullDate.string(from: trip.metadata.dateInterval.start)
        endDateTextField.text = DateFormatter.fullDate.string(from: trip.metadata.dateInterval.end)
    }
    
    // MARK: - UITextFieldDelegate
    
    private var startText: String?
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        startText = textField.text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard
            startText != textField.text,
            let search = textField.text,
            search.isEmpty == false
        else {
            return
        }
        
        let searchTableViewController = LocationSearchTableViewController.init(search, delegate: self)
        let searchPopup = PopupDialog.init(viewController: searchTableViewController)
        present(searchPopup, animated: true)
    }
    
    // MARK: - LocationSearchTableViewControllerDelegate
    
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, selectedLocationListing locationListing: LocationListing) {
        dismiss(animated: true)
        builder.address = locationListing.address
        cityTextField.text = locationListing.displayText
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
                        strongSelf.showOneOptionAlert(title: "Success!", message: successMessage)
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
        
        OperationQueue.main.addOperation(editOperation)
    }
    
    @IBAction private func deleteTrip() {
        // TODO: Delete trip from FireBase
    }
}
