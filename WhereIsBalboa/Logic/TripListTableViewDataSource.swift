import UIKit
import CoreLocation

class TripListTableViewDataSource: NSObject, UITableViewDataSource {
    typealias DataChangeHandler = () -> Void
    
    private static let reuseIdentifier = "cell"
    
    private let baseUser: Balbabe?
    private var configuration: TripsDataConfiguration
    private var orderedTrips: [(Trip, Balbabe)]
    var onDataChange: DataChangeHandler?
    
    // MARK: - Init
    
    init(_ configuration: TripsDataConfiguration, relativeToUser baseUser: Balbabe, onDataChange: DataChangeHandler? = nil) {
        self.baseUser = baseUser
        self.configuration = configuration
        self.orderedTrips = TripListTableViewDataSource.sortedTrips(from: configuration, relativeToUser: baseUser)
        self.onDataChange = onDataChange
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
        let trip = tripInfoAt(indexPath).0
        guard let balbabe = configuration.keyedBalbabes[trip] else {
            // TODO: Log error
            cell.nameLabel.text = "Encountered an error"
            cell.cityLabel.text = "We're working on fixing it"
            cell.dateLabel.text = "Please download a newer version if it exists"
            return cell
        }
        
        let isLoggedInUserTrip = balbabe == baseUser
        cell.nameLabel.text = isLoggedInUserTrip ? "You" : balbabe.name
        cell.cityLabel.text = "will be in \(trip.metadata.address.city), \(trip.metadata.address.country)"
        var durationText = "from \(DateFormatter.fullDate.string(from: trip.metadata.dateInterval.start)) "
        if trip.metadata.dateInterval.end == Date.distantFuture {
            let pronoun = isLoggedInUserTrip ? "you" : "they"
            durationText += "until \(pronoun) go traveling again!"
        } else {
            durationText += "to \(DateFormatter.fullDate.string(from: trip.metadata.dateInterval.end))"
        }
        cell.dateLabel.text = durationText
        
        cell.contactButton.isHidden = isLoggedInUserTrip
        
        let distanceDetails: (String, UIColor)
        
        if isLoggedInUserTrip {
            distanceDetails = ("", .black)
        } else {
            let distance = configuration.currentLocation.distance(from: trip.metadata.address.location)
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
        }
        
        let (distanceText, indicatorColor) = distanceDetails
        cell.distanceLabel.text = distanceText
        cell.distanceLabel.textColor = indicatorColor
        cell.locationImageView.tintColor = indicatorColor
        let image = trip.metadata.isHome ? #imageLiteral(resourceName: "home") : #imageLiteral(resourceName: "plane")
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
        onDataChange?()
    }
    
    func tripInfoAt(_ indexPath: IndexPath) -> (Trip, Balbabe) {
        return orderedTrips[indexPath.item]
    }
    
    // MARK: - Helpers
    
    private static func sortedTrips(from configuration: TripsDataConfiguration, relativeToUser baseUser: Balbabe?) -> [(Trip, Balbabe)] {
        let trips = Array(configuration.keyedBalbabes.keys).sorted {
            return $0.metadata.address.location.distance(from: configuration.currentLocation) < $1.metadata.address.location.distance(from: configuration.currentLocation) }
        return trips.map { ($0, configuration.keyedBalbabes[$0]!) }
    }
}
