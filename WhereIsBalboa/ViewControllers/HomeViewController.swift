import UIKit
import CoreLocation
import FirebaseDatabase

class HomeViewController: UIViewController {
    @IBOutlet private var balbabeViewControllerContainer: UIView!
    @IBOutlet private var profileBarButtonItem: UIBarButtonItem!
    @IBOutlet private var tripsBarButtonItem: UIBarButtonItem!
    @IBOutlet private var dateSelectionTextField: UITextField!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var doneInputAccessory: UIToolbar!
    @IBOutlet private var dateStepper: UIStepper!
    
    private var tripViewType: TripViewType
    private var currentDate = Date()
    
    private let loadingViewController = LoadingViewController()
    private var databaseObservationInfo: (String, UInt)!
    private var tripListTableViewController: TripListTableViewController?
    private var tripMapViewController: TripMapViewController?
    private var configuration: HomeViewControllerConfiguration
    private var hasUpdatedWhileViewLoaded = false
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe) {
        configuration = HomeViewControllerConfiguration(loggedInBalbabe: balbabe, balbabes: [], focusedDate: Date())
        tripViewType = .loading(loadingViewController)
        super.init(nibName: nil, bundle: nil)
        
        let referencePath = "balbabes"
        let observationIdentifier = Database.database().reference(withPath: referencePath).observe(.value) { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            guard let balbabeSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                // TODO: Log error
                return
            }
            
            do {
                let updatedBalbabes = try balbabeSnapshots.flatMap { try Balbabe($0) }
                guard let loggedInBalbabe = updatedBalbabes.first(where: { $0.id == strongSelf.configuration.loggedInBalbabe.id }) else {
                    // TODO: Log error
                    return
                }
                var updatedConfiguration = strongSelf.configuration
                updatedConfiguration.balbabes = updatedBalbabes
                updatedConfiguration.loggedInBalbabe = loggedInBalbabe
                strongSelf.updateConfiguration(to: updatedConfiguration)
            } catch {
                // TODO: Log error
            }
        }
        databaseObservationInfo = (referencePath, observationIdentifier)
        
        guard #available(iOS 11.0, *) else {
            edgesForExtendedLayout = []
            return
        }
    }
    
    deinit {
        Database.database().reference(withPath: databaseObservationInfo.0).removeObserver(withHandle: databaseObservationInfo.1)
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
        updateConfigurationForNewDate(currentDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if currentDate.timeIntervalSinceNow > 0 {
            currentDate = Date()
            datePicker.minimumDate = currentDate
            updateConfigurationForNewDate(currentDate)
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
        let profileViewController = ProfileViewController(configuration.loggedInBalbabe)
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @IBAction private func goToTrips() {
        let tripsViewController = BalbabeTripListTableViewController(configuration.loggedInBalbabe, isLoggedInUser: true)
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
        updateConfigurationForNewDate(datePicker.date)
    }
    
    @IBAction private func stepDate(_ stepper: UIStepper) {
        updateConfigurationForNewDate(currentDate.date(daysLater: Int(stepper.value)))
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
    
    private func updateConfigurationForNewDate(_ date: Date) {
        var updatedConfiguration = configuration
        updatedConfiguration.focusedDate = date
        updateConfiguration(to: updatedConfiguration)
    }
    
    private func updateConfiguration(to configuration: HomeViewControllerConfiguration) {
        guard self.configuration != configuration || !hasUpdatedWhileViewLoaded else {
            return
        }
        self.configuration = configuration
        
        if
            isViewLoaded,
            !hasUpdatedWhileViewLoaded
        {
            hasUpdatedWhileViewLoaded = true
        }
        
        let focusedDate = configuration.focusedDate
        let balbabes = configuration.balbabes
        let loggedInBalbabe = configuration.loggedInBalbabe
        
        if isViewLoaded {
            dateStepper.value = Double(focusedDate.daysSince(currentDate))
            datePicker.date = focusedDate
            dateSelectionTextField.text = DateFormatter.fullDate.string(from: focusedDate)
        }
        
        let keyedBalbabes = balbabes.reduce([Trip: Balbabe]()) { aggregate, balbabe in
            var updated = aggregate
            let trip = tripOf(balbabe, for: focusedDate)
            updated[trip] = balbabe
            return updated
        }
        let configuration = TripsDataConfiguration(loggedInBalbabe: loggedInBalbabe, keyedBalbabes: keyedBalbabes, currentLocation: tripOf(loggedInBalbabe, for: focusedDate).metadata.address.location)
        
        if let tripListTableViewController = tripListTableViewController {
            tripListTableViewController.update(configuration)
        } else {
            tripListTableViewController = TripListTableViewController(configuration, relativeToUser: loggedInBalbabe) { [weak self] _, balbabe in
                guard let strongSelf = self else {
                    return
                }
                let loggedInBalbabe = strongSelf.configuration.loggedInBalbabe
                let balbabeTripListViewController = BalbabeTripListTableViewController.init(balbabe, isLoggedInUser: balbabe == loggedInBalbabe)
                strongSelf.navigationController?.pushViewController(balbabeTripListViewController, animated: true)
            }
        }
        
        if let tripMapViewController = tripMapViewController {
            tripMapViewController.update(configuration)
        } else {
            let tripMapViewController = TripMapViewController(configuration,
                onTripTap: { [weak self] _, balbabe in
                    guard let strongSelf = self else {
                        return
                    }
                    let loggedInBalbabe = strongSelf.configuration.loggedInBalbabe
                
                    let balbabeTripListViewController = BalbabeTripListTableViewController.init(balbabe, isLoggedInUser: balbabe == loggedInBalbabe)
                    strongSelf.navigationController?.pushViewController(balbabeTripListViewController, animated: true)
                }, onTripGroupTap: { [weak self] keyedBalbabes in
                    guard let strongSelf = self else {
                        return
                    }
                    let focusedDate = strongSelf.configuration.focusedDate
                    let loggedInBalbabe = strongSelf.configuration.loggedInBalbabe
                    let configuration = TripsDataConfiguration(loggedInBalbabe: loggedInBalbabe, keyedBalbabes: keyedBalbabes, currentLocation: strongSelf.tripOf(loggedInBalbabe, for: focusedDate).metadata.address.location)
                    let tripListTableViewController = TripListTableViewController(configuration, relativeToUser: loggedInBalbabe) { _, balbabe in
                        let balbabeTripListViewController = BalbabeTripListTableViewController.init(balbabe, isLoggedInUser: balbabe == loggedInBalbabe)
                        self?.navigationController?.pushViewController(balbabeTripListViewController, animated: true)
                    }
                    strongSelf.navigationController?.pushViewController(tripListTableViewController, animated: true)
            })
            self.tripMapViewController = tripMapViewController
        }
        
        if
            isViewLoaded,
            tripViewType.isLoading,
            let tripMapViewController = tripMapViewController
        {
            updateTripViewType(to: .map(tripMapViewController))
        }
    }
    
    private func tripOf(_ balbabe: Balbabe, for date: Date) -> Trip {
        if let trip = balbabe.trips.first(where: { $0.metadata.dateInterval.contains(date) }) {
            return trip
        }
        let hometown = balbabe.metadata.hometown
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
