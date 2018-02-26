import UIKit
import Firebase
import CoreLocation

class TripListTableViewController: UIViewController, UITableViewDelegate {
    typealias TripTapHandler = (Trip, User) -> Void
    
    @IBOutlet private var tableView: UITableView!
    
    private let dataSource: TripListTableViewDataSource
    private let baseUser: User
    var onTripTap: TripTapHandler?
    
    // MARK: - Init
    
    init(_ configuration: TripsDataConfiguration, relativeToUser baseUser: User, onTripTap: TripTapHandler? = nil) {
        dataSource = TripListTableViewDataSource(configuration)
        self.baseUser = baseUser
        self.onTripTap = onTripTap
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
        automaticallyAdjustsScrollViewInsets = false
        dataSource.dataChangeHandler = { [weak tableView] in
            tableView?.reloadData()
        }
        dataSource.registerCells(with: tableView)
        tableView.dataSource = dataSource
        tableView.reloadData()
        tableView.delegate = self
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let (trip, user) = dataSource.tripInfoAt(indexPath)
        onTripTap?(trip, user)
    }
    
    // MARK: - Accessors
    
    func update(_ configuration: TripsDataConfiguration) {
        dataSource.update(configuration)
    }
}
