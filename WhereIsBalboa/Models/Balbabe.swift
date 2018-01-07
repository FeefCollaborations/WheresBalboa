import Foundation
import CoreLocation

struct Balbabe: Equatable {
    typealias ID = String
    
    let id: ID
    let name: String
    let whatsapp: String?
    let hometown: Address
    let trips: [Trip]
    let hometownIntervals: [DateInterval]
    
    init(id: ID, name: String, whatsapp: String?, hometown: Address, trips: [Trip]) {
        self.id = id
        self.name = name
        self.whatsapp = whatsapp
        self.hometown = hometown
        self.trips = trips
        self.hometownIntervals = Balbabe.hometownIntervalsFor(trips)
    }
    
    private static func hometownIntervalsFor(_ trips: [Trip]) -> [DateInterval] {
        let now = Date()
        let upcomingTrips = trips.filter { $0.metadata.dateInterval.end > now }
        let sortedTrips = upcomingTrips.sorted { $0.metadata.dateInterval.start < $1.metadata.dateInterval.start }
        guard let firstTrip = sortedTrips.first else {
            return [DateInterval(start: now - 1000, end: Date.distantFuture)]
        }
        var intervals = [DateInterval]()
        var previousTripEnd: Date
        var tripsToCheck = sortedTrips
        if firstTrip.metadata.dateInterval.contains(now) {
            tripsToCheck.removeFirst()
            previousTripEnd = firstTrip.metadata.dateInterval.end
        } else {
            previousTripEnd = now - 1000
        }
        tripsToCheck.forEach {
            intervals.append(DateInterval(start: previousTripEnd, end: $0.metadata.dateInterval.start))
            previousTripEnd = $0.metadata.dateInterval.end
        }
        intervals.append(DateInterval(start: previousTripEnd, end: Date.distantFuture))
        return intervals
    }
    
    private static var dummyID = "|"
    private static func dummyHometown() -> Address {
        let randomLat = Double(arc4random_uniform(18000)) / 100
        let randomLon = Double(arc4random_uniform(18000)) / 100
        return Address(location: CLLocation(latitude: randomLat - 90, longitude: randomLon - 90), city: "home", state: "home", country: "home country")
    }
    static func dummy(_ name: String, _ hometown: Address = dummyHometown()) -> Balbabe {
        var trips = [Trip]()
        let dateOffset = TimeInterval(arc4random_uniform(60 * 60 * 24 * 5))
        var startDate = Date().addingTimeInterval(dateOffset)
        (0...30).forEach { _ in
            trips.append(.dummy(startDate: startDate))
            startDate = trips.last!.metadata.dateInterval.end.addingTimeInterval(dateOffset)
        }
        let balbabe = Balbabe(id: dummyID, name: name, whatsapp: "+61414491231", hometown: hometown, trips: trips)
        dummyID += "|"
        return balbabe
    }
}

func ==(lhs: Balbabe, rhs: Balbabe) -> Bool {
    return
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.whatsapp == rhs.whatsapp &&
        lhs.hometown == rhs.hometown &&
        lhs.trips == rhs.trips
}
