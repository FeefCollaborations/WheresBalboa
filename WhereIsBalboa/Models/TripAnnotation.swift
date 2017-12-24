import MapKit

class TripAnnotation: MKPointAnnotation {
    let balbabe: Balbabe
    let trip: Trip
    
    init(_ balbabe: Balbabe, _ trip: Trip) {
        self.balbabe = balbabe
        self.trip = trip
        super.init()
        coordinate = trip.location.coordinate
        title = balbabe.name
        subtitle = "\(DateFormatter.fullDate.string(from: trip.startDate)) - \(DateFormatter.fullDate.string(from: trip.endDate))"
    }
}
