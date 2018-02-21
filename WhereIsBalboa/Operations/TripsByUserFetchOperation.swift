import Foundation
import FirebaseDatabase

class TripsByUserFetchOperation: AsynchronousOperation, ResultGeneratingOperation {
    typealias Completion = (Result<[Trip]>) -> Void
    
    private let user: User
    private let cohort: Cohort
    private var databaseObservationHandle: UInt?
    private lazy var databaseReference = Database.database().reference(withPath: cohort.rawValue + "/trips")
    let onComplete: Completion
    init(_ user: User, _ cohort: Cohort, onComplete: @escaping Completion) {
        self.user = user
        self.cohort = cohort
        self.onComplete = onComplete
    }
    
    deinit {
        guard let databaseObservationHandle = databaseObservationHandle else {
            return
        }
        databaseReference.removeObserver(withHandle: databaseObservationHandle)
    }
    
    override func start() {
        super.start()
        databaseObservationHandle = databaseReference.queryOrdered(byChild: Trip.DBValues.userID).queryEqual(toValue: user.id).observe(.value, with: { [weak self] snapshot in
            do {
                guard let tripSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                    throw DatabaseConversionError.invalidSnapshot(snapshot)
                }
                let trips = try tripSnapshots.map { try Trip($0) }
                self?.onComplete(.success(trips))
            } catch let error {
                self?.onComplete(.failure(error))
            }
            if self?.state != .finished {
                self?.state = .finished
            }
            }, withCancel: { [weak self] error in
                self?.onComplete(.failure(error))
                if self?.state != .finished {
                    self?.state = .finished
            }
        })
    }
}

