import UIKit
import FirebaseDatabase
import SwiftyJSON

class TripGroupCreateOperation: AsynchronousOperation, ResultGeneratingOperation {
    typealias Completion = (Result<[Trip]>) -> Void
    let userManager: UserManager
    let tripMetadatas: [TripMetadata]
    let onComplete: Completion
    
    // MARK: - Init
    
    init(_ userManager: UserManager, _ tripMetadatas: [TripMetadata], onComplete: @escaping Completion) {
        self.userManager = userManager
        self.tripMetadatas = tripMetadatas
        self.onComplete = onComplete
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        let tripsReference = Database.database().reference(withPath: "\(userManager.cohort.rawValue)/trips")
        let trips = tripMetadatas.map { Trip(id: tripsReference.childByAutoId().key, metadata: $0, userID: userManager.loggedInUser.id) }
        let childValues = trips.reduce([String: Any]()) { aggregate, trip in
            var updated = aggregate
            updated[trip.id] = trip.dictionaryRepresentation()
            return updated
        }
        tripsReference.updateChildValues(childValues) { [weak self] error, reference in
            guard let strongSelf = self else {
                return
            }
            defer {
                strongSelf.state = .finished
            }
            
            if let error = error {
                strongSelf.onComplete(.failure(error))
                return
            }
            strongSelf.onComplete(.success(trips))
        }
    }
}

