import UIKit
import CoreLocation

class LocationSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    static let cellReuseIdentifier = "cell"
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingView: LoadingView!
    
    private let searchText: String
    private var locationDescriptions: [String]?
    private weak var delegate: LocationSearchTableViewControllerDelegate?
    
    // MARK: - Initialization
    
    init(_ searchText: String, delegate: LocationSearchTableViewControllerDelegate) {
        self.searchText = searchText
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        performSearch()
        guard #available(iOS 11.0, *) else {
            edgesForExtendedLayout = []
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: LocationSearchTableViewController.cellReuseIdentifier)
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        updateSubviewVisibility()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let locationDescriptions = locationDescriptions,
            locationDescriptions.isEmpty == false
        else {
            return 0
        }
        return locationDescriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationSearchTableViewController.cellReuseIdentifier, for: indexPath)
        guard let locationDescription = locationDescriptions?[indexPath.item] else {
            // TODO: Log error
            cell.textLabel?.text = "We encountered an error :/ working to fix it!"
            return cell
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = locationDescription
        cell.backgroundColor = .clear
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let locationDescription = locationDescriptions?[indexPath.item] else {
            return
        }
        tableView.isHidden = true
        loadingView.update(to: .loading)
        do {
            let geocodeTask = try CityGeocodeTaskWrapper.geocode(locationDescription) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                    case .success(let locationListing):
                        DispatchQueue.main.async {
                            strongSelf.delegate?.locationSearchTableViewController(strongSelf, selectedLocationListing: locationListing)
                        }
                    case .failure:
                        // TODO: Improve this flow
                        return
                }
            }
            geocodeTask.resume()
        } catch {
            // TODO: Log error
        }
    }
    
    // MARK: - Subview visibility management
    
    private func updateSubviewVisibility() {
        guard isViewLoaded else {
            return
        }
        
        if locationDescriptions?.isEmpty == false {
            tableView.isHidden = false
            tableView.reloadData()
        } else if currentSearch == nil {
            loadingView.update(to: .failed(displayText: "Failed to find any matching cities. Please try again."))
        }
    }
    
    // MARK: - Search management
    
    private var currentSearch: URLSessionDataTask?
    
    private func performSearch() {
        do {
            let currentSearch = try CitySearchTaskWrapper.newSearchFor(cityName: searchText) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.currentSearch = nil
                switch result {
                    case .success(let locationDescriptions):
                        strongSelf.locationDescriptions = Array(locationDescriptions)
                    case .failure: ()
                }
                
                DispatchQueue.main.async {
                    strongSelf.updateSubviewVisibility()
                }
            }
            self.currentSearch = currentSearch
            currentSearch.resume()
        } catch {
            // TODO: Log error
        }
    }
}
