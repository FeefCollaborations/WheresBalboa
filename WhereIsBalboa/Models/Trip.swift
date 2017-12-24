import MapKit

struct Trip: Equatable, Hashable {
    typealias ID = String
    
    let id: ID
    let location: CLLocation
    let startDate: Date
    let endDate: Date
    let city: String
    let isHome: Bool
    
    private static var dummyID = "|"
    static func dummy() -> Trip {
        let latOffset = Double(arc4random_uniform(100)) / 100
        let lonOffset = Double(arc4random_uniform(100)) / 100
        let dateOffset = TimeInterval(arc4random_uniform(60 * 60 * 24 * 10))
        let trip = Trip(id: dummyID, location: CLLocation.init(latitude: 6.2 + latOffset, longitude: -75.5 + lonOffset), startDate: Date().addingTimeInterval(dateOffset), endDate: Date().addingTimeInterval(dateOffset + 60 * 60 * 24), city: "city", isHome: false)
        dummyID += "|"
        return trip
    }
    
    // MARK: - Hashable
    
    var hashValue: Int {
        return id.hashValue
    }
}

func ==(lhs: Trip, rhs: Trip) -> Bool {
    return
        lhs.id == rhs.id &&
        lhs.location == rhs.location &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.city == rhs.city &&
        lhs.isHome == rhs.isHome
}
