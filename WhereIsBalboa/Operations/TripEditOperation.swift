import UIKit
import FirebaseDatabase
import SwiftyJSON

class TripEditOperation: AsynchronousOperation, ResultGeneratingOperation {
    typealias Completion = (Result<Trip>) -> Void
    let balbabe: Balbabe
    let tripMetadata: TripMetadata
    let onComplete: Completion
    let tripID: Trip.ID?
    
    // MARK: - Builder
    
    struct Builder {
        var balbabe: Balbabe?
        var address: Address?
        var startDate: Date?
        var endDate: Date?
        var tripID: Trip.ID?
        
        func build(onComplete: @escaping Completion) -> TripEditOperation? {
            guard
                let balbabe = balbabe,
                let address = address,
                let startDate = startDate,
                let endDate = endDate
            else {
                return nil
            }
            let dateInterval = DateInterval.init(start: startDate, end: endDate)
            return TripEditOperation.init(balbabe, address, dateInterval, tripID, onComplete: onComplete)
        }
    }
    
    // MARK: - Init
    
    init(_ balbabe: Balbabe, _ address: Address, _ dateInterval: DateInterval, _ tripID: Trip.ID? = nil, onComplete: @escaping Completion) {
        self.balbabe = balbabe
        self.tripMetadata = TripMetadata(address: address, dateInterval: dateInterval, isHome: false)
        self.tripID = tripID
        self.onComplete = onComplete
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        let tripReference: DatabaseReference
        if let tripID = tripID {
            tripReference = Database.database().reference(withPath: "balbabes/\(balbabe.id)/trips/\(tripID)")
        } else {
            tripReference = Database.database().reference(withPath: "balbabes/\(balbabe.id)/trips").childByAutoId()
        }
        
        tripReference.setValue(tripMetadata.dictionaryRepresentation()) { [weak self] error, _ in
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
            let trip = Trip(id: tripReference.key, metadata: strongSelf.tripMetadata)
            strongSelf.onComplete(.success(trip))
        }
    }
}
