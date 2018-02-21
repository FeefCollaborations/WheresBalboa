import UIKit
import CoreLocation

class TripListTableViewDataSource: NSObject, UITableViewDataSource {
    typealias DataChangeHandler = () -> Void
    
    private static let reuseIdentifier = "cell"
    
    private var configuration: TripsDataConfiguration
    private var orderedTrips: [(Trip, User)] {
        didSet {

        }
    }
    var dataChangeHandler: DataChangeHandler?
    
    // MARK: - Init
    
    init(_ configuration: TripsDataConfiguration, dataChangeHandler: DataChangeHandler? = nil) {
        self.configuration = configuration
        self.orderedTrips = TripListTableViewDataSource.sortedTrips(from: configuration)
        self.dataChangeHandler = dataChangeHandler
        super.init()
        
        configuration.userManager.registerForChanges { [weak self] userManager in
            guard let strongSelf = self else {
                return
            }
            
            let loggedInUser = userManager.loggedInUser
            
            var updatedConfiguration = strongSelf.configuration
            updatedConfiguration.currentLocation = userManager.loggedInUserLocation(at: updatedConfiguration.focusedDate)
            let loggedInUserTrips = userManager.loggedInUserTrips
            let visibleTrip = loggedInUserTrips.first(where: { $0.metadata.dateInterval.contains(updatedConfiguration.focusedDate) })
            if
                let oldTrip = updatedConfiguration.keyedUsers.first(where: { $1.id == loggedInUser.id })?.0,
                oldTrip != visibleTrip
            {
                updatedConfiguration.keyedUsers[oldTrip] = nil
            }
            
            if let visibleTrip = visibleTrip {
                updatedConfiguration.keyedUsers[visibleTrip] = loggedInUser
            }
            
            strongSelf.configuration = updatedConfiguration
            strongSelf.orderedTrips = TripListTableViewDataSource.sortedTrips(from: updatedConfiguration)
            
            DispatchQueue.main.async {
                strongSelf.dataChangeHandler?()
            }
        }
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
        guard let user = configuration.keyedUsers[trip] else {
            // TODO: Log error
            cell.nameLabel.text = "Encountered an error"
            cell.cityLabel.text = "We're working on fixing it"
            cell.dateLabel.text = "Please download a newer version if it exists"
            return cell
        }
        
        let isLoggedInUserTrip = user == configuration.userManager.loggedInUser
        cell.nameLabel.text = isLoggedInUserTrip ? "You" : user.metadata.name
        
        let verb = self.verb(for: trip.metadata.dateInterval, isLoggedInUser: isLoggedInUserTrip)
        cell.cityLabel.text = "\(verb) in \(trip.metadata.address.cityName)"
        let startDate = trip.metadata.dateInterval.start
        let endDate = trip.metadata.dateInterval.end
        var durationText = startDate.isDistantPast ? "since ages ago " : "from \(DateFormatter.fullDateShortenedYear.string(from: startDate)) "
        if endDate.isDistantFuture {
            let pronoun = isLoggedInUserTrip ? "you" : "they"
            durationText += "until \(pronoun) go traveling again!"
        } else {
            durationText += "to \(DateFormatter.fullDateShortenedYear.string(from: endDate))"
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
        
        cell.onContactTapped = { _ in
            UIApplication.shared.open(user.metadata.whatsappURL, options: [:])
        }
        
        return cell
    }
    
    // MARK: - Accessors
    
    func update(_ configuration: TripsDataConfiguration) {
        guard self.configuration != configuration else {
            return
        }
        self.configuration = configuration
        self.orderedTrips = TripListTableViewDataSource.sortedTrips(from: configuration)
        dataChangeHandler?()
    }
    
    func tripInfoAt(_ indexPath: IndexPath) -> (Trip, User) {
        return orderedTrips[indexPath.item]
    }
    
    // MARK: - Helpers
    
    private func verb(for dateInterval: DateInterval, isLoggedInUser: Bool) -> String {
        let currentDate = Date()
        if dateInterval.contains(currentDate) {
            return isLoggedInUser ? "are" : "is"
        } else if currentDate.compare(dateInterval.end) == ComparisonResult.orderedDescending {
            return isLoggedInUser ? "were" : "was"
        } else {
            return "will be"
        }
    }
    
    private static func sortedTrips(from configuration: TripsDataConfiguration) -> [(Trip, User)] {
        let trips = Array(configuration.keyedUsers.keys).sorted {
            return $0.metadata.address.location.distance(from: configuration.currentLocation) < $1.metadata.address.location.distance(from: configuration.currentLocation) || configuration.keyedUsers[$0] == configuration.userManager.loggedInUser }
        return trips.map { ($0, configuration.keyedUsers[$0]!) }
    }
}
