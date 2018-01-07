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
    
    private let balbabe: Balbabe
    private let loadingViewController = LoadingViewController()
    private var tripListTableViewController: TripListTableViewController?
    private var tripMapViewController: TripMapViewController?
    private var balbabes = [Balbabe]()
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe) {
        self.balbabe = balbabe
        tripViewType = .loading(loadingViewController)
        super.init(nibName: nil, bundle: nil)
        
        // TODO: Add actual balbabe array observing here
        self.balbabes = [balbabe, .dummy("annabel"), .dummy("mikey"), .dummy("liz"), .dummy("smashley"), .dummy("debs")]
        updateSubviewsFor(focusedDate: focusedDate)
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
        navigationItem.leftBarButtonItem = profileBarButtonItem
        navigationItem.rightBarButtonItem = tripsBarButtonItem
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        doneInputAccessory.translatesAutoresizingMaskIntoConstraints = false
        dateSelectionTextField.inputView = datePicker
        dateSelectionTextField.inputAccessoryView = doneInputAccessory
        addTripViewer(tripViewType.viewController)
        currentDate = Date()
        datePicker.minimumDate = currentDate
        updateFocusedDate(to: currentDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if currentDate.timeIntervalSinceNow > 0 {
            currentDate = Date()
            datePicker.minimumDate = currentDate
            updateFocusedDate(to: currentDate)
        }
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
        let tripsViewController = BalbabeTripListTableViewController(balbabe, isLoggedInUser: true)
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
        containedView.frame = balbabeViewControllerContainer.bounds
        containedView.translatesAutoresizingMaskIntoConstraints = false
        balbabeViewControllerContainer.addSubview(containedView)
        containedView.addFitToParentContraints()
        viewController.didMove(toParentViewController: self)
        containedView.layoutIfNeeded()
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
        updateSubviewsFor(focusedDate: focusedDate)
    }
    
    private func updateSubviewsFor(focusedDate: Date) {
        let keyedBalbabes = balbabes.reduce([Trip: Balbabe]()) { aggregate, balbabe in
            var updated = aggregate
            let trip = tripOf(balbabe, for: focusedDate)
            updated[trip] = balbabe
            return updated
        }
        let configuration = TripsDataConfiguration(keyedBalbabes: keyedBalbabes, currentLocation: tripOf(balbabe, for: focusedDate).metadata.address.location)
        
        if let tripListTableViewController = tripListTableViewController {
            tripListTableViewController.update(configuration)
        } else {
            tripListTableViewController = TripListTableViewController(configuration, relativeToUser: balbabe) { [weak self] _, balbabe in
                let balbabeTripListViewController = BalbabeTripListTableViewController.init(balbabe, isLoggedInUser: balbabe == self?.balbabe)
                self?.navigationController?.pushViewController(balbabeTripListViewController, animated: true)
            }
        }
        
        if let tripMapViewController = tripMapViewController {
            tripMapViewController.update(configuration)
        } else {
            let tripMapViewController = TripMapViewController(configuration, loggedInUser: balbabe, onTripTap: { [weak self] _, balbabe in
                let balbabeTripListViewController = BalbabeTripListTableViewController.init(balbabe, isLoggedInUser: balbabe == self?.balbabe)
                self?.navigationController?.pushViewController(balbabeTripListViewController, animated: true)
            }, onTripGroupTap: { [weak self] keyedBalbabes in
                guard let strongSelf = self else {
                    return
                }
                let configuration = TripsDataConfiguration(keyedBalbabes: keyedBalbabes, currentLocation: strongSelf.tripOf(strongSelf.balbabe, for: strongSelf.focusedDate).metadata.address.location)
                let tripListTableViewController = TripListTableViewController(configuration, relativeToUser: strongSelf.balbabe) { _, balbabe in
                    let balbabeTripListViewController = BalbabeTripListTableViewController.init(balbabe, isLoggedInUser: balbabe == self?.balbabe)
                    self?.navigationController?.pushViewController(balbabeTripListViewController, animated: true)
                }
                strongSelf.navigationController?.pushViewController(tripListTableViewController, animated: true)
            })
            tripViewType = .map(tripMapViewController)
            self.tripMapViewController = tripMapViewController
        }
    }
    
    private func tripOf(_ balbabe: Balbabe, for date: Date) -> Trip {
        if let trip = balbabe.trips.first(where: { $0.metadata.dateInterval.contains(date) }) {
            return trip
        }
        let hometown = balbabe.hometown
        let homeInterval: DateInterval
        if let interval = balbabe.hometownIntervals.first(where: { $0.contains(date) }) {
            homeInterval = interval
        } else {
            // TODO: Log error
            homeInterval = DateInterval(start: Date(), end: Date.distantFuture)
        }
        let metadata = TripMetadata(address: hometown, dateInterval: homeInterval, isHome: true)
        return Trip(id: balbabe.id, metadata: metadata)
    }
}
