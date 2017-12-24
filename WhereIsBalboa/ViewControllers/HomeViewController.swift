import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    @IBOutlet private var balbabeViewControllerContainer: UIView!
    @IBOutlet private var profileBarButtonItem: UIBarButtonItem!
    @IBOutlet private var tripsBarButtonItem: UIBarButtonItem!
    @IBOutlet private var dateSelectionTextField: UITextField!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var doneInputAccessory: UIToolbar!
    @IBOutlet private var dateStepper: UIStepper!
    
    private var tripViewType: TripViewType
    private var focusedDate = Date()
    private var currentDate = Date()
    
    let balbabe: Balbabe
    let loadingViewController = LoadingViewController()
    var tripListTableViewController: TripListTableViewController?
    var tripMapViewController: TripMapViewController?
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe) {
        self.balbabe = balbabe
        tripViewType = .loading(loadingViewController)
        super.init(nibName: nil, bundle: nil)
        
        // TODO: Add actual balbabe array observing here
        let balbabes: [Balbabe] = [balbabe, .dummy(), .dummy(), .dummy(), .dummy(), .dummy()]
        let keyedBalbabes = balbabes.reduce([Trip: Balbabe]()) { aggregate, balbabe in
            var updated = aggregate
            updated[balbabe.trips[0]] = balbabe
            return updated
        }
        let configuration = TripsDataConfiguration(keyedBalbabes: keyedBalbabes, currentLocation: balbabe.trips[0].location)
        tripListTableViewController = TripListTableViewController(configuration, relativeToUser: balbabe)
        let tripMapViewController = TripMapViewController(configuration, loggedInUser: balbabe, onTripTap: { _ in
            // TODO: Show action sheet for reaching out to balbabe associated with the trip
        }, onTripGroupTap: { [weak self] keyedBalbabes in
            let configuration = TripsDataConfiguration(keyedBalbabes: keyedBalbabes, currentLocation: configuration.currentLocation)
            let tripListTableViewController = TripListTableViewController(configuration, relativeToUser: balbabe)
            self?.navigationController?.pushViewController(tripListTableViewController, animated: true)
        })
        tripViewType = .map(tripMapViewController)
        self.tripMapViewController = tripMapViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = profileBarButtonItem
        navigationItem.rightBarButtonItem = tripsBarButtonItem
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        doneInputAccessory.translatesAutoresizingMaskIntoConstraints = false
        dateSelectionTextField.inputView = datePicker
        dateSelectionTextField.inputAccessoryView = doneInputAccessory
        addTripViewer(tripViewType.viewController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        currentDate = Date()
        datePicker.minimumDate = currentDate
        updateFocusedDate(to: currentDate)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Workaround for iOS 11.2 highlight bug
        profileBarButtonItem.isEnabled = false
        tripsBarButtonItem.isEnabled = false
        profileBarButtonItem.isEnabled = true
        tripsBarButtonItem.isEnabled = true
    }
    
    // MARK: - Button response
    
    @IBAction private func goToProfile() {
        let profileViewController = ProfileViewController(balbabe)
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @IBAction private func goToTrips() {
        let tripsViewController = UserTripListTableViewController(balbabe)
        navigationController?.pushViewController(tripsViewController, animated: true)
    }
    
    @IBAction private func toggleTripViewType() {
        guard
            let tripListTableViewController = tripListTableViewController,
            let tripMapViewController = tripMapViewController
        else {
            return
        }
        
        let newTripViewType: TripViewType
        switch tripViewType {
            case .loading:
                return
            case .map:
                newTripViewType = .list(tripListTableViewController)
            case .list:
                newTripViewType = .map(tripMapViewController)
        }
        updateTripViewType(to: newTripViewType)
    }
    
    @IBAction private func doneTappedOnPicker() {
        dateSelectionTextField.resignFirstResponder()
        updateFocusedDate(to: datePicker.date)
    }
    
    @IBAction private func stepDate(_ stepper: UIStepper) {
        updateFocusedDate(to: currentDate.date(daysLater: Int(stepper.value)))
    }
    
    // MARK: - Trip view management
    
    private func updateTripViewType(to tripViewType: TripViewType) {
        guard self.tripViewType != tripViewType else {
            return
        }
        
        let currentChildViewController = self.tripViewType.viewController
        currentChildViewController.willMove(toParentViewController: nil)
        currentChildViewController.view.removeFromSuperview()
        self.tripViewType = tripViewType
        addTripViewer(tripViewType.viewController)
    }
    
    private func addTripViewer(_ viewController: UIViewController) {
        let containedView: UIView = viewController.view
        containedView.translatesAutoresizingMaskIntoConstraints = false
        balbabeViewControllerContainer.addSubview(containedView)
        containedView.addFitToParentContraints()
        viewController.didMove(toParentViewController: self)
    }
    
    // MARK: - Date management
    
    private func updateFocusedDate(to date: Date) {
        guard focusedDate != date else {
            return
        }
        focusedDate = date
        dateStepper.value = Double(focusedDate.daysSince(currentDate))
        datePicker.date = focusedDate
        dateSelectionTextField.text = DateFormatter.fullDate.string(from: focusedDate)
        
        // TODO: Filter trips based on date and update configurations of map and trip list accordingly
    }
}
