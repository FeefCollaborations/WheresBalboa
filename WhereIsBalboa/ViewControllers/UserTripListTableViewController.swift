import UIKit

class UserTripListTableViewController: UIViewController, UITableViewDelegate {
    private lazy var newTripBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTrip))
    
    private let userManager: UserManager
    private let isLoggedInUser: Bool
    private let trips: [Trip]
    private let dataSource: UserTripListTableViewDataSource
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Init
    
    init(_ userManager: UserManager, _ user: User, _ trips: [Trip]) {
        self.trips = trips
        self.userManager = userManager
        let isLoggedInUser = user.id == userManager.loggedInUser.id
        self.isLoggedInUser = isLoggedInUser
        dataSource = UserTripListTableViewDataSource(userManager, user, trips)
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
        if isLoggedInUser {
            navigationItem.rightBarButtonItem = newTripBarButtonItem
        } else {
            let whatappBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "chatBubble").scaled(toSize: CGSize(width: 20, height: 20)), style: .plain, target: self, action: #selector(tappedContact))
            navigationItem.setRightBarButton(whatappBarButtonItem, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.dataChangeHandler = { [weak self] in
            self?.tableView.reloadData()
        }
        dataSource.registerCells(with: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = self
        let titleText = isLoggedInUser ? "Your trips" : "\(dataSource.user.metadata.name)'s trips"
        navigationItem.titleView = UIView.viewControllerTitleView(title: titleText, subtitle: "based out of \(dataSource.user.metadata.hometown.cityName)")
        tableView.allowsSelection = isLoggedInUser
    }
    
    // MARK: - Button response
    
    @objc private func addNewTrip() {
        let tripEditorViewController = TripEditorViewController(userManager)
        navigationController?.pushViewController(tripEditorViewController, animated: true)
    }
    
    @objc private func tappedContact() {
        UIApplication.shared.open(dataSource.user.metadata.whatsappURL, options: [:])
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tripEditorViewController = TripEditorViewController(userManager, dataSource.tripAt(indexPath))
        navigationController?.pushViewController(tripEditorViewController, animated: true)
    }
}
