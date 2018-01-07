import UIKit
import CoreLocation

class UserTripListTableViewDataSource: NSObject, UITableViewDataSource {
    private static let reuseIdentifier = "tripTableViewCell"
    
    private var trips: [Trip]
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe) {
        let upcomingTrips = balbabe.trips.filter { $0.metadata.dateInterval.start > Date() }
        trips = upcomingTrips.sorted { $0.metadata.dateInterval.start < $1.metadata.dateInterval.start }
        super.init()
        
        // TODO: Listen for balbabe changes
    }
    
    func registerCells(with tableView: UITableView) {
        tableView.register(OwnTripTableViewCell.nib, forCellReuseIdentifier: UserTripListTableViewDataSource.reuseIdentifier)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTripListTableViewDataSource.reuseIdentifier, for: indexPath) as! OwnTripTableViewCell
        let trip = tripAt(indexPath)
                
        cell.cityLabel.text = "\(trip.metadata.address.city), \(trip.metadata.address.country)"
        cell.dateLabel.text = "from \(DateFormatter.fullDate.string(from: trip.metadata.dateInterval.start)) to \(DateFormatter.fullDate.string(from: trip.metadata.dateInterval.end))"
        
        return cell
    }
    
    // MARK: - Accessors
    
    func tripAt(_ indexPath: IndexPath) -> Trip {
        return trips[indexPath.item]
    }
}
