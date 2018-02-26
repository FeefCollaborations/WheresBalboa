import Foundation
import FirebaseAuth
import FirebaseDatabase

class UserCreateOperation: AsynchronousOperation, ResultGeneratingOperation {
    struct Builder {
        var hometown: Address?
        var whatsapp: String?
        var userID: String?
        var name: String?
        var cohort: Cohort?
        
        func build(onComplete: @escaping Completion) throws -> UserCreateOperation {
            guard
                let hometown = hometown,
                let whatsapp = whatsapp,
                let userID = userID,
                let cohort = cohort,
                let name = name
            else {
                throw OperationBuilderError.missingValues
            }
            let userMetadata = try UserMetadata(name: name, whatsapp: whatsapp, hometown: hometown)
            return UserCreateOperation(userMetadata, cohort, userID: userID, onComplete: onComplete)
        }
    }
    
    // MARK: - Initialization
    
    typealias Completion = (Result<User>) -> Void
    let onComplete: Completion
    let userMetadata: UserMetadata
    let userID: String
    let databaseReference: DatabaseReference
    init(_ userMetadata: UserMetadata, _ cohort: Cohort, userID: String, onComplete: @escaping Completion) {
        self.userMetadata = userMetadata
        self.userID = userID
        databaseReference = Database.database().reference(withPath: cohort.rawValue + "/users/" + userID)
        self.onComplete = onComplete
        super.init()
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        // TODO: Also update signUpCodes payload here
        databaseReference.setValue(userMetadata.dictionaryRepresentation()) { [weak self] error, reference in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                strongSelf.onComplete(.failure(error))
                strongSelf.state = .finished
                return
            }
            
            let user = User(id: strongSelf.userID, metadata: strongSelf.userMetadata)
            strongSelf.onComplete(.success(user))
            strongSelf.state = .finished
        }
    }
}
