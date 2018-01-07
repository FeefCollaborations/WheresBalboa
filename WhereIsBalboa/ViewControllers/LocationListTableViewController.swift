import UIKit
import CoreLocation

class LocationSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    static let cellReuseIdentifier = "cell"
    
    @IBOutlet private var tableView: UITableView!
    
    private let searchText: String
    private var locations: [LocationListing] = []
    private weak var delegate: LocationListTableViewControllerDelegate?
    
    // MARK: - Initialization
    
    init(_ searchText: String, delegate: LocationListTableViewControllerDelegate) {
        self.searchText = searchText
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: LocationSearchTableViewController.cellReuseIdentifier)
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        // TODO: Search for hometown here, use results to update tableView
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationSearchTableViewController.cellReuseIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = locations[indexPath.item].displayText
        cell.backgroundColor = .clear
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.item]
        delegate?.locationListTableViewController(self, selectedLocationListing: location)
    }
    
}
