import UIKit

class UserTripListTableViewController: UIViewController, UITableViewDelegate {
    private lazy var newTripBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTrip))
    
    let balbabe: Balbabe
    private let dataSource: UserTripListTableViewDataSource
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe) {
        self.balbabe = balbabe
        dataSource = UserTripListTableViewDataSource(balbabe)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = newTripBarButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.registerCells(with: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = self
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
