import UIKit
import CoreLocation

class BalbabeTripListTableViewDataSource: NSObject, UITableViewDataSource {
    private static let reuseIdentifier = "tripTableViewCell"
    
    typealias DataChangeHandler = () -> Void
    var dataChangeHandler: DataChangeHandler?
    private var trips: [Trip]
    private(set) var user: User
    
    // MARK: - Init
    
    init(_ userManager: UserManager, _ user: User, _ trips: [Trip]) {
        self.user = user
        self.trips = BalbabeTripListTableViewDataSource.sortedTrips(from: trips)
        super.init()
        if userManager.loggedInUser == user {
            userManager.registerForChanges { [weak self] userManager in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.user = userManager.loggedInUser
                strongSelf.trips = BalbabeTripListTableViewDataSource.sortedTrips(from: userManager.loggedInUserTrips)
                DispatchQueue.main.async {
                    strongSelf.dataChangeHandler?()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerCells(with tableView: UITableView) {
        tableView.register(OwnTripTableViewCell.nib, forCellReuseIdentifier: BalbabeTripListTableViewDataSource.reuseIdentifier)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BalbabeTripListTableViewDataSource.reuseIdentifier, for: indexPath) as! OwnTripTableViewCell
        let trip = tripAt(indexPath)
                
        cell.cityLabel.text = "\(trip.metadata.address.cityName)"
        let startDate = trip.metadata.dateInterval.start
        let endDate = trip.metadata.dateInterval.end
        let startDateString = startDate.isDistantPast ? "∞" : DateFormatter.fullDateShortenedYear.string(from: startDate)
        let endDateString = endDate.isDistantFuture ? "∞" : DateFormatter.fullDateShortenedYear.string(from: endDate)
        cell.dateLabel.text = "from " + startDateString + " to " + endDateString
        
        return cell
    }
    
    // MARK: - Helpers
    
    private static func sortedTrips(from trips: [Trip]) -> [Trip] {
        return trips.sorted { $0.metadata.dateInterval.start < $1.metadata.dateInterval.start }
    }
    
    // MARK: - Accessors
    
    func tripAt(_ indexPath: IndexPath) -> Trip {
        return trips[indexPath.item]
    }
}
