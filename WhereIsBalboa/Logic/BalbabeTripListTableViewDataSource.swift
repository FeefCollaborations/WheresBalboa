import UIKit
import CoreLocation

class BalbabeTripListTableViewDataSource: NSObject, UITableViewDataSource {
    private static let reuseIdentifier = "tripTableViewCell"
    
    typealias DataChangeHandler = () -> Void
    var dataChangeHandler: DataChangeHandler?
    private var trips: [Trip]
    private(set) var balbabe: Balbabe
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe, isLoggedInUser: Bool) {
        self.balbabe = balbabe
        trips = BalbabeTripListTableViewDataSource.upcomingTrips(from: balbabe.trips)
        super.init()
        if isLoggedInUser {
            NotificationCenter.default.registerForUserChanges { [weak self] balbabe in
                guard
                    let strongSelf = self,
                    let balbabe = balbabe
                else {
                    return
                }
                
                strongSelf.balbabe = balbabe
                strongSelf.trips = BalbabeTripListTableViewDataSource.upcomingTrips(from: balbabe.trips)
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
                
        cell.cityLabel.text = "\(trip.metadata.address.name)"
        cell.dateLabel.text = "from \(DateFormatter.fullDate.string(from: trip.metadata.dateInterval.start)) to \(DateFormatter.fullDate.string(from: trip.metadata.dateInterval.end))"
        
        return cell
    }
    
    // MARK: - Helpers
    
    private static func upcomingTrips(from trips: [Trip]) -> [Trip] {
        let upcomingTrips = trips.filter { Date().daysSince($0.metadata.dateInterval.end) <= 0 }
        return upcomingTrips.sorted { $0.metadata.dateInterval.start < $1.metadata.dateInterval.start }
    }
    
    // MARK: - Accessors
    
    func tripAt(_ indexPath: IndexPath) -> Trip {
        return trips[indexPath.item]
    }
}
