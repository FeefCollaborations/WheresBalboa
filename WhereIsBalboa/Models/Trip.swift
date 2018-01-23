import MapKit
import FirebaseDatabase

struct Trip: Equatable, Hashable {
    typealias ID = String
    
    let id: ID
    let metadata: TripMetadata
    
    init(_ dataSnapshot: DataSnapshot) throws {
        id = dataSnapshot.key
        metadata = try TripMetadata(dataSnapshot)
    }
    
    init(id: ID, metadata: TripMetadata) {
        self.id = id
        self.metadata = metadata
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
