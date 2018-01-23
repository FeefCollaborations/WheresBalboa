import MapKit

class TripAnnotation: MKPointAnnotation {
    let balbabe: Balbabe
    let trip: Trip
    
    init(_ balbabe: Balbabe, _ trip: Trip, isLoggedInUser: Bool = false) {
        self.balbabe = balbabe
        self.trip = trip
        super.init()
        coordinate = trip.metadata.address.location.coordinate
        title = isLoggedInUser ? "You" : balbabe.metadata.name
        subtitle = "\(DateFormatter.fullDate.string(from: trip.metadata.displayStartDate)) - \(DateFormatter.fullDate.string(from: trip.metadata.displayEndDate))"
    }
}
