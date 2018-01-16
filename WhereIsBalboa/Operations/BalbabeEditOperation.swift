import UIKit
import FirebaseDatabase
import SwiftyJSON

class BalbabeEditOperation: AsynchronousOperation {
    enum Result {
        case success, failure(Error)
    }
    
    typealias Completion = (Result) -> Void
    let balbabeMetadata: BalbabeMetadata
    let balbabeID: Balbabe.ID
    let onComplete: Completion
    
    // MARK: - Init
    
    init(balbabeMetadata: BalbabeMetadata, balbabeID: Balbabe.ID, onComplete: @escaping Completion) {
        self.balbabeMetadata = balbabeMetadata
        self.balbabeID = balbabeID
        self.onComplete = onComplete
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        let balbabeReference = Database.database().reference(withPath: "balbabes/" + balbabeID)
        let valuesDictionary: [String: Any] = [
            "name": balbabeMetadata.name,
            "whatsapp": balbabeMetadata.whatsapp,
            "hometown": balbabeMetadata.hometown.dictionaryRepresentation()
        ]
        balbabeReference.updateChildValues(valuesDictionary) { [weak self] error, _ in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                strongSelf.onComplete(.failure(error))
            } else {
                strongSelf.onComplete(.success)
            }
            strongSelf.state = .finished
        }
    }
}

