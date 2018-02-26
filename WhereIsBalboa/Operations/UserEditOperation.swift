import UIKit
import FirebaseDatabase
import SwiftyJSON

class UserEditOperation: AsynchronousOperation {
    enum Result {
        case success, failure(Error)
    }
    
    typealias Completion = (Result) -> Void
    let userMetadata: UserMetadata
    let userManager: UserManager
    let onComplete: Completion
    
    // MARK: - Init
    
    init(_ userMetadata: UserMetadata, _ userManager: UserManager, onComplete: @escaping Completion) {
        self.userMetadata = userMetadata
        self.userManager = userManager
        self.onComplete = onComplete
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        let userReference = Database.database().reference(withPath: userManager.cohort.rawValue + "/users/" + userManager.loggedInUser.id)
        var valuesDictionary: [String: Any] = [
            "name": userMetadata.name,
            "whatsapp": userMetadata.whatsapp,
        ]
        userMetadata.hometown.dictionaryRepresentation().forEach {
            valuesDictionary[$0] = $1
        }
        userReference.updateChildValues(valuesDictionary) { [weak self] error, _ in
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

