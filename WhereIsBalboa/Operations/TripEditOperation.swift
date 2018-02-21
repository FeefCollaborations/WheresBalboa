import UIKit
import FirebaseDatabase
import SwiftyJSON

class TripEditOperation: AsynchronousOperation, ResultGeneratingOperation {
    typealias Completion = (Result<Trip>) -> Void
    let userManager: UserManager
    let tripMetadata: TripMetadata
    let onComplete: Completion
    let tripID: Trip.ID?
    
    // MARK: - Builder
    
    struct Builder {
        var userManager: UserManager?
        var address: Address?
        var startDate: Date?
        var endDate: Date?
        var tripID: Trip.ID?
        
        func build(onComplete: @escaping Completion) -> TripEditOperation? {
            guard
                let userManager = userManager,
                let address = address,
                let startDate = startDate,
                let endDate = endDate
            else {
                return nil
            }
            let dateInterval = DateInterval.init(start: startDate, end: endDate)
            return TripEditOperation(userManager, address, dateInterval, tripID, onComplete: onComplete)
        }
    }
    
    // MARK: - Init
    
    init(_ userManager: UserManager, _ address: Address, _ dateInterval: DateInterval, _ tripID: Trip.ID? = nil, onComplete: @escaping Completion) {
        self.userManager = userManager
        self.tripMetadata = TripMetadata(address: address, dateInterval: dateInterval, isHome: false)
        self.tripID = tripID
        self.onComplete = onComplete
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        let tripReference: DatabaseReference
        let pathRoot = "\(userManager.cohort.rawValue)/trips"
        if let tripID = tripID {
            tripReference = Database.database().reference(withPath: pathRoot + "/" + tripID)
        } else {
            tripReference = Database.database().reference(withPath: pathRoot).childByAutoId()
        }
        let trip = Trip(id: tripReference.key, metadata: tripMetadata, userID: userManager.loggedInUser.id)
        tripReference.setValue(trip.dictionaryRepresentation()) { [weak self] error, _ in
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
            strongSelf.onComplete(.success(trip))
        }
    }
}
