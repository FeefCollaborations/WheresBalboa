import UIKit
import CoreLocation
import FirebaseDatabase

class HomeViewController: UIViewController {
    @IBOutlet private var userViewControllerContainer: UIView!
    @IBOutlet private var profileBarButtonItem: UIBarButtonItem!
    @IBOutlet private var tripsBarButtonItem: UIBarButtonItem!
    @IBOutlet private var dateSelectionTextField: UITextField!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var doneInputAccessory: UIToolbar!
    
    private var state = HomeViewControllerState.loading {
        didSet {
            guard case let .populated(userManager, trips, _) = state else {
                navigationItem.titleView = loadingIndicator
                return
            }
            navigationItem.titleView = nil
            let configuration = TripsDataConfiguration(userManager, trips, focusedDate: focusedDate)
            updateTripMapViewController(for: configuration)
            updateTripListViewController(for: configuration)
            guard
                let mapViewController = tripMapViewController,
                let listViewController = tripListTableViewController
            else {
                return
            }
            updateToForegroundChildViewController(tripViewType == .map ? mapViewController : listViewController)
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
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingIndicator.color = .black
        loadingIndicator.startAnimating()
        return loadingIndicator
    }()
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
            guard
                let strongSelf = self,
                case let .populated(_, trips, _) = strongSelf.state
            else {
                return
            }
            
            let focusedDate = strongSelf.focusedDate
            
            var updatedTrips = trips
            userManager.loggedInUserTrips.filter({ $0.metadata.dateInterval.contains(focusedDate) }).forEach { updatedTrip in
                if let oldTripIndex = updatedTrips.index(where: { updatedTrip.id == $0.id && updatedTrip != $0 }) {
                    updatedTrips.remove(at: oldTripIndex)
                }
                updatedTrips.append(updatedTrip)
            }
            if updatedTrips != trips {
                strongSelf.state = HomeViewControllerState.populated(userManager: userManager, trips: updatedTrips, focusedDate: focusedDate)
            }
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
        let profileViewController = ProfileViewController(userManager)
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @IBAction private func goToTrips() {
        let tripsViewController = UserTripListTableViewController(userManager, userManager.loggedInUser, userManager.loggedInUserTrips)
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
    
    @IBAction private func tappedAddNewTrip() {
        let addTripViewController = TripEditorViewController(userManager)
        navigationController?.pushViewController(addTripViewController, animated: true)
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
        self.tripViewType = tripViewType
        updateToForegroundChildViewController(tripViewType == .map ? mapViewController : listViewController)
    }
    
    private func updateToForegroundChildViewController(_ viewController: UIViewController) {
        if let currentChildViewController = childViewControllers.first {
            currentChildViewController.willMove(toParentViewController: nil)
            currentChildViewController.view.removeFromSuperview()
        }
        addTripViewer(viewController)
    }
    
    private func addTripViewer(_ viewController: UIViewController) {
        let containedView: UIView = viewController.view
        containedView.frame = userViewControllerContainer.bounds
        containedView.translatesAutoresizingMaskIntoConstraints = false
        userViewControllerContainer.addSubview(containedView)
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
                }, onTripGroupTap: { [weak self] keyedUsers in
                    guard let strongSelf = self else {
                        return
                    }
                    let userManager = strongSelf.userManager
                    let loggedInUser = userManager.loggedInUser
                    let configuration = TripsDataConfiguration(userManager, keyedUsers.keys.map { $0 }, focusedDate: strongSelf.focusedDate)
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
                            let userTripListViewController = UserTripListTableViewController(strongSelf.userManager, user, trips)
                            strongSelf.navigationController?.pushViewController(userTripListViewController, animated: true)
                    }
                }
            }
        }
        showLoadingAlert()
        OperationQueue.main.addOperation(tripsFetchOperation)
    }
}
