import CoreLocation

struct TripsDataConfiguration: Equatable {
    let keyedBalbabes: [Trip: Balbabe]
    let currentLocation: CLLocation
}

func ==(lhs: TripsDataConfiguration, rhs: TripsDataConfiguration) -> Bool {
    return
        lhs.keyedBalbabes == rhs.keyedBalbabes &&
        lhs.currentLocation == rhs.currentLocation
}
