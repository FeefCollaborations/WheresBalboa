import Foundation
import FirebaseDatabase

struct User: Equatable {
    typealias ID = String
    
    let id: ID
    let metadata: UserMetadata
    
    init(_ dataSnapshot: DataSnapshot) throws {
        metadata = try UserMetadata(dataSnapshot)
        id = dataSnapshot.key
    }
    
    init(id: ID, metadata: UserMetadata) {
        self.id = id
        self.metadata = metadata
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return
        lhs.id == rhs.id &&
        lhs.metadata == rhs.metadata
}
