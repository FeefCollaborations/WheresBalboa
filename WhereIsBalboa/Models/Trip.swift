import MapKit

struct Trip: Equatable, Hashable {
    typealias ID = String
    
    let id: ID
    let metadata: TripMetadata
    
    private static var dummyID = "|"
    
    static func dummy(startDate: Date) -> Trip {
        let latOffset = Double(arc4random_uniform(100)) / 100
        let lonOffset = Double(arc4random_uniform(100)) / 100
        let dateOffset = TimeInterval(arc4random_uniform(60 * 60 * 24 * 2))
        let address = Address(location: CLLocation.init(latitude: 6.2 + latOffset, longitude: -75.5 + lonOffset), city: "city", state: "state", country: "country")
        let metadata = TripMetadata(address: address, dateInterval: DateInterval.init(start: startDate, end: startDate.addingTimeInterval(dateOffset + 60 * 60 * 24)), isHome: false)
        let trip = Trip(id: dummyID, metadata: metadata)
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
        lhs.metadata == rhs.metadata
}
