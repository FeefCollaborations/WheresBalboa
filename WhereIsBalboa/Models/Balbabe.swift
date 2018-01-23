import Foundation
import CoreLocation
import FirebaseDatabase

struct Balbabe: Equatable {
    typealias ID = String
    
    let id: ID
    let metadata: BalbabeMetadata
    let trips: [Trip]
    let hometownIntervals: [DateInterval]
    
    init(_ dataSnapshot: DataSnapshot) throws {
        metadata = try BalbabeMetadata(dataSnapshot)
        if let tripSnapshots = dataSnapshot.childSnapshot(forPath: "trips").children.allObjects as? [DataSnapshot] {
            trips = try tripSnapshots.flatMap { try Trip($0) }
        } else {
            trips = []
        }
        id = dataSnapshot.key
        hometownIntervals = Balbabe.hometownIntervalsFor(trips)
    }
    
    init(id: ID, metadata: BalbabeMetadata, trips: [Trip] = []) {
        self.id = id
        self.metadata = metadata
        self.trips = trips
        hometownIntervals = Balbabe.hometownIntervalsFor(trips)
    }
    
    private static func hometownIntervalsFor(_ trips: [Trip]) -> [DateInterval] {
        let past = Date.distantPast
        guard !trips.isEmpty else {
            return [DateInterval(start: past, end: Date.distantFuture)]
        }
        let sortedTrips = trips.sorted { $0.metadata.dateInterval.start < $1.metadata.dateInterval.start }
        var intervals = [DateInterval]()
        var previousTripEnd = past
        sortedTrips.forEach {
            intervals.append(DateInterval(start: previousTripEnd, end: $0.metadata.dateInterval.start))
            previousTripEnd = $0.metadata.dateInterval.end
        }
        intervals.append(DateInterval(start: previousTripEnd, end: Date.distantFuture))
        return intervals
    }
}

func ==(lhs: Balbabe, rhs: Balbabe) -> Bool {
    return
        lhs.id == rhs.id &&
        lhs.metadata == rhs.metadata &&
        lhs.trips == rhs.trips
}
