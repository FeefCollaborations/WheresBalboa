import UIKit
import Firebase
import CoreLocation

class TripListTableViewController: UIViewController, UITableViewDelegate {
    typealias TripTapHandler = (Trip) -> Void
    
    @IBOutlet private var tableView: UITableView!
    
    private let dataSource: TripListTableViewDataSource
    private let baseUser: Balbabe
    var onTripTap: TripTapHandler?
    
    // MARK: - Init
    
    init(_ configuration: TripsDataConfiguration, relativeToUser baseUser: Balbabe, onTripTap: TripTapHandler? = nil) {
        dataSource = TripListTableViewDataSource(configuration, relativeToUser: baseUser)
        self.baseUser = baseUser
        self.onTripTap = onTripTap
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
        dataSource.registerCells(with: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onTripTap?(dataSource.tripAt(indexPath))
    }
    
    // MARK: - Accessors
    
    func update(_ configuration: TripsDataConfiguration) {
        dataSource.update(configuration)
    }
}
