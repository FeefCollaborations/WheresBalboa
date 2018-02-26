import UIKit
import FirebaseDatabase
import SwiftyJSON

class TripDeleteOperation: AsynchronousOperation {
    enum Result {
        case success, failure(Error)
    }
    
    typealias Completion = (Result) -> Void
    let onComplete: Completion
    let cohort: Cohort
    let tripID: Trip.ID
    
    // MARK: - Init
    
    init(_ cohort: Cohort, _ tripID: Trip.ID, onComplete: @escaping Completion) {
        self.cohort = cohort
        self.tripID = tripID
        self.onComplete = onComplete
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        let tripReference = Database.database().reference(withPath: cohort.rawValue + "/trips/" + tripID)
        tripReference.removeValue() { [weak self] error, _ in
            guard let strongSelf = self else {
                return
            }
            
            defer {
                strongSelf.state = .finished
            }
            
            if let error = error {
                // TODO: Log error
                strongSelf.onComplete(.failure(error))
            } else {
                strongSelf.onComplete(.success)
            }
        }
    }
}

