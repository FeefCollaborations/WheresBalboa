import MapKit
import FirebaseDatabase

struct Trip: Equatable, Hashable, DatabaseConvertible {
    struct DBValues {
        static let userID = "uid"
    }
    
    typealias ID = String
    
    let id: ID
    let metadata: TripMetadata
    let userID: User.ID
    
    init(_ dataSnapshot: DataSnapshot) throws {
        guard let userID = dataSnapshot.childSnapshot(forPath: DBValues.userID).value as? String else {
            throw DatabaseConversionError.invalidSnapshot(dataSnapshot)
        }
        self.init(id: dataSnapshot.key, metadata: try TripMetadata(dataSnapshot), userID: userID)
    }
    
    init(id: ID, metadata: TripMetadata, userID: User.ID) {
        self.id = id
        self.metadata = metadata
        self.userID = userID
    }
    
    // MARK: - DatabaseConvertible
    
    func dictionaryRepresentation() -> [String : Any] {
        var dictionary = metadata.dictionaryRepresentation()
        dictionary[DBValues.userID] = userID
        return dictionary
    }
        
    // MARK: - Hashable
    
    var hashValue: Int {
        return id.hashValue
    }
}

func ==(lhs: Trip, rhs: Trip) -> Bool {
    return
        lhs.id == rhs.id &&
        lhs.metadata == rhs.metadata &&
        lhs.userID == rhs.userID
}
