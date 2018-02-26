import MapKit

class TripAnnotation: MKPointAnnotation {
    let user: User
    let trip: Trip
    
    init(_ user: User, _ trip: Trip, isLoggedInUser: Bool = false) {
        self.user = user
        self.trip = trip
        super.init()
        coordinate = trip.metadata.address.location.coordinate
        title = isLoggedInUser ? "You" : user.metadata.name
        let startDate = trip.metadata.dateInterval.start
        let endDate = trip.metadata.dateInterval.end
        let startDateString = startDate.isDistantPast ? "∞" : DateFormatter.fullDateShortenedYear.string(from: startDate)
        let endDateString = endDate.isDistantFuture ? "∞" : DateFormatter.fullDateShortenedYear.string(from: endDate)
        subtitle = startDateString + " - " + endDateString
    }
}
