import UIKit

class TripEditorTableViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var cityTextField: UITextField!
    @IBOutlet private var startDateTextField: UITextField!
    @IBOutlet private var endDateTextField: UITextField!
    
    let balbabe: Balbabe
    let trip: Trip?
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe, _ trip: Trip? = nil) {
        self.balbabe = balbabe
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
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
            return
        }
        cityTextField.text = trip.city
        startDateTextField.text = DateFormatter.fullDate.string(from: trip.startDate)
        endDateTextField.text = DateFormatter.fullDate.string(from: trip.endDate)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: Do city search based on textField text
    }
}
