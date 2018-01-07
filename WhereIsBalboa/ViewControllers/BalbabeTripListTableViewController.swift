import UIKit

class BalbabeTripListTableViewController: UIViewController, UITableViewDelegate {
    private lazy var newTripBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTrip))
    
    private let balbabe: Balbabe
    private let isLoggedInUser: Bool
    private let dataSource: UserTripListTableViewDataSource
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe, isLoggedInUser: Bool) {
        self.balbabe = balbabe
        self.isLoggedInUser = isLoggedInUser
        dataSource = UserTripListTableViewDataSource(balbabe)
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.registerCells(with: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = self
        let titleText = isLoggedInUser ? "Your trips" : "\(balbabe.name)'s trips"
        navigationItem.titleView = UIView.viewControllerTitleView(title: titleText, subtitle: "based out of \(balbabe.hometown.city), \(balbabe.hometown.country)")
        tableView.allowsSelection = isLoggedInUser
    }
    
    // MARK: - Button response
    
    @objc private func addNewTrip() {
        let tripEditorViewController = TripEditorTableViewController(balbabe)
        navigationController?.pushViewController(tripEditorViewController, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tripEditorViewController = TripEditorTableViewController(balbabe, dataSource.tripAt(indexPath))
        navigationController?.pushViewController(tripEditorViewController, animated: true)
    }
}
