import UIKit
import CoreLocation

class TripListTableViewDataSource: NSObject, UITableViewDataSource {
    private static let reuseIdentifier = "cell"
    
    private let baseUser: Balbabe?
    private var configuration: TripsDataConfiguration
    private var orderedTrips: [Trip]
    
    // MARK: - Init
    
    init(_ configuration: TripsDataConfiguration, relativeToUser baseUser: Balbabe) {
        self.baseUser = baseUser
        self.configuration = configuration
        self.orderedTrips = TripListTableViewDataSource.sortedTrips(from: configuration, relativeToUser: baseUser)
        super.init()
    }
    
    func registerCells(with tableView: UITableView) {
        tableView.register(TripTableViewCell.nib, forCellReuseIdentifier: TripListTableViewDataSource.reuseIdentifier)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripListTableViewDataSource.reuseIdentifier, for: indexPath) as! TripTableViewCell
        let trip = tripAt(indexPath)
        guard let balbabe = configuration.keyedBalbabes[trip] else {
            // TODO: Log error
            cell.nameLabel.text = "Encountered an error"
            cell.cityLabel.text = "We're working on fixing it"
            cell.dateLabel.text = "Please download a newer version if it exists"
            return cell
        }
        
        cell.nameLabel.text = balbabe == baseUser ? "You" : balbabe.name
        cell.cityLabel.text = "will be in \(trip.city)"
        cell.dateLabel.text = "from \(DateFormatter.fullDate.string(from: trip.startDate)) to \(DateFormatter.fullDate.string(from: trip.endDate))"
        
        let distanceDetails: (String, UIColor)
        let distance = configuration.currentLocation.distance(from: trip.location)
        switch distance {
            case 0..<1000:
                distanceDetails = ("<1KM", .green)
            case 1001..<5000:
                distanceDetails = ("<5KM", .cyan)
            case 5001..<10000:
                distanceDetails = ("<10KM", .blue)
            case 10001..<50000:
                distanceDetails = ("<50KM", .magenta)
            case 50001..<100000:
                distanceDetails = ("<100KM", .orange)
            default:
                distanceDetails = ("100+KM", .red)
        }
        let (distanceText, indicatorColor) = distanceDetails
        cell.distanceLabel.text = distanceText
        cell.distanceLabel.textColor = indicatorColor
        cell.locationImageView.tintColor = indicatorColor
        let image = trip.isHome ? #imageLiteral(resourceName: "home") : #imageLiteral(resourceName: "plane")
        cell.locationImageView.image = image.withRenderingMode(.alwaysTemplate)
        
        return cell
    }
    
    // MARK: - Accessors
    
    func update(_ configuration: TripsDataConfiguration) {
        guard self.configuration != configuration else {
            return
        }
        self.configuration = configuration
        self.orderedTrips = TripListTableViewDataSource.sortedTrips(from: configuration, relativeToUser: baseUser)
    }
    
    func tripAt(_ indexPath: IndexPath) -> Trip {
        return orderedTrips[indexPath.item]
    }
    
    // MARK: - Helpers
    
    private static func sortedTrips(from configuration: TripsDataConfiguration, relativeToUser baseUser: Balbabe?) -> [Trip] {
        return Array(configuration.keyedBalbabes.keys).sorted { $0.location.distance(from: configuration.currentLocation) < $1.location.distance(from: configuration.currentLocation) }
    }
}
