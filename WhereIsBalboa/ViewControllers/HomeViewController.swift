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
    
    private var state = HomeViewControllerState.loading {
        didSet {
            guard case let .populated(userManager, trips, _) = state else {
                // TODO: Populate for loading
                return
            }
            let configuration = TripsDataConfiguration(userManager, trips, focusedDate: focusedDate)
            updateTripMapViewController(for: configuration)
            updateTripListViewController(for: configuration)
        }
    }
    private var tripViewType = TripViewType.map
    private var currentTripFetch: TripsByDateFetchOperation?
    private var currentDate = Date().startOfDay()
    private var focusedDate = Date().startOfDay() {
        didSet {
            dateSelectionTextField.text = DateFormatter.fullDateShortenedYear.string(from: focusedDate)
            currentTripFetch?.cancel()
            let tripFetchOperation = TripsByDateFetchOperation(focusedDate, userManager.cohort) { result in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    switch result {
                        case .failure:
                            // TODO: Log error
                            return
                        case .success(let trips):
                            strongSelf.state = .populated(userManager: strongSelf.userManager, trips: trips, focusedDate: strongSelf.focusedDate)
                    }
                }
            }
            state = .loading
            currentTripFetch = tripFetchOperation
            OperationQueue.main.addOperation(tripFetchOperation)
        }
    }
    
    private let loadingViewController = LoadingViewController()
    private var tripListTableViewController: TripListTableViewController?
    private var tripMapViewController: TripMapViewController?
    private var userManager: UserManager
    private var hasUpdatedWhileViewLoaded = false
    
    // MARK: - Init
    
    init(_ userManager: UserManager) {
        self.userManager = userManager
        super.init(nibName: nil, bundle: nil)
        
        userManager.registerForChanges { [weak self] userManager in
            self?.userManager = userManager
        }
                
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
        currentDate = Date().startOfDay()
        dateStepper.minimumValue = -Double.infinity
        focusedDate = currentDate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        let focusedDateIsCurrent = focusedDate == currentDate
        if currentDate.daysSince(Date()) < 0 {
            currentDate = Date().startOfDay()
            if focusedDateIsCurrent {
                focusedDate = currentDate
            }
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
        let profileViewController = ProfileViewController(userManager.loggedInUser)
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @IBAction private func goToTrips() {
        let tripsViewController = BalbabeTripListTableViewController(userManager, userManager.loggedInUser, userManager.loggedInUserTrips)
        navigationController?.pushViewController(tripsViewController, animated: true)
    }
    
    @IBAction private func toggleTripViewType() {
        let newTripViewType: TripViewType
        switch tripViewType {
            case .map:
                newTripViewType = .list
            case .list:
                newTripViewType = .map
        }
        updateTripViewType(to: newTripViewType)
    }
    
    @IBAction private func doneTappedOnPicker() {
        dateSelectionTextField.resignFirstResponder()
        focusedDate = datePicker.date.startOfDay()
    }
    
    @IBAction private func stepDate(_ stepper: UIStepper) {
        focusedDate = currentDate.date(daysLater: Int(stepper.value)).startOfDay()
    }
    
    // MARK: - Trip view management
    
    private func updateTripViewType(to tripViewType: TripViewType) {
        guard
            self.tripViewType != tripViewType,
            let mapViewController = tripMapViewController,
            let listViewController = tripListTableViewController
        else {
            return
        }
        
        let currentChildViewController: UIViewController = self.tripViewType == .map ? mapViewController : listViewController
        currentChildViewController.willMove(toParentViewController: nil)
        currentChildViewController.view.removeFromSuperview()
        self.tripViewType = tripViewType
        addTripViewer(tripViewType == .map ? mapViewController : listViewController)
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
    
    private func updateTripListViewController(for configuration: TripsDataConfiguration) {
        if let tripListTableViewController = tripListTableViewController {
            tripListTableViewController.update(configuration)
        } else {
            tripListTableViewController = TripListTableViewController(configuration, relativeToUser: userManager.loggedInUser) { [weak self] _, user in
                self?.showTripListViewController(for: user)
            }
        }
    }
    
    private func updateTripMapViewController(for configuration: TripsDataConfiguration) {
        if let tripMapViewController = tripMapViewController {
            tripMapViewController.update(configuration)
        } else {
            let tripMapViewController = TripMapViewController(
                configuration,
                onTripTap: { [weak self] _, user in
                    self?.showTripListViewController(for: user)
                }, onTripGroupTap: { [weak self] keyedBalbabes in
                    guard let strongSelf = self else {
                        return
                    }
                    let userManager = strongSelf.userManager
                    let loggedInUser = userManager.loggedInUser
                    let configuration = TripsDataConfiguration(userManager, keyedBalbabes.keys.map { $0 }, focusedDate: strongSelf.focusedDate)
                    let tripListTableViewController = TripListTableViewController(configuration, relativeToUser: loggedInUser) { _, user in
                        strongSelf.showTripListViewController(for: user)
                    }
                    strongSelf.navigationController?.pushViewController(tripListTableViewController, animated: true)
            })
            self.tripMapViewController = tripMapViewController
        }
    }
    
    private func showTripListViewController(for user: User) {
        let tripsFetchOperation = TripsByUserFetchOperation(user, userManager.cohort) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.dismiss(animated: true) {
                    switch result {
                    case .failure:
                        // TODO: Log error
                        strongSelf.showRetryAlert(message: "Failed to load all of that user's trips. Retry?", retryHandler: { strongSelf.showTripListViewController(for: user) })
                    case .success(let trips):
                        let balbabeTripListViewController = BalbabeTripListTableViewController(strongSelf.userManager, user, trips)
                        strongSelf.navigationController?.pushViewController(balbabeTripListViewController, animated: true)
                    }
                }
            }
        }
        showLoadingAlert()
        OperationQueue.main.addOperation(tripsFetchOperation)
    }
}
