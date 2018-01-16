import CoreLocation

struct TripsDataConfiguration: Equatable {
    let loggedInBalbabe: Balbabe
    let keyedBalbabes: [Trip: Balbabe]
    let currentLocation: CLLocation
}

func ==(lhs: TripsDataConfiguration, rhs: TripsDataConfiguration) -> Bool {
    return
        lhs.loggedInBalbabe == rhs.loggedInBalbabe &&
        lhs.keyedBalbabes == rhs.keyedBalbabes &&
        lhs.currentLocation == rhs.currentLocation
}
