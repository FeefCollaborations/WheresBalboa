import MapKit

struct Address: Equatable {
    let location: CLLocation
    let city: String
    let state: String
    let country: String
}

func ==(lhs: Address, rhs: Address) -> Bool {
    return
        lhs.location == rhs.location &&
        lhs.city == rhs.city &&
        lhs.state == rhs.state &&
        lhs.country == rhs.country
}
