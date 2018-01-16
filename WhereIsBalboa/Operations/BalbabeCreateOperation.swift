import Foundation
import FirebaseAuth
import FirebaseDatabase

class BalbabeCreateOperation: AsynchronousOperation, ResultGeneratingOperation {
    struct Builder {
        var name: String?
        var hometown: Address?
        var whatsapp: String?
        var email: String?
        var password: String?
        
        func build(onComplete: @escaping Completion) throws -> BalbabeCreateOperation {
            guard
                let name = name,
                let hometown = hometown,
                let whatsapp = whatsapp,
                let email = email,
                let password = password
            else {
                throw OperationBuilderError.missingValues
            }
            let balbabeMetadata = try BalbabeMetadata(name: name, whatsapp: whatsapp, hometown: hometown)
            return BalbabeCreateOperation(balbabeMetadata: balbabeMetadata, email: email, password: password, onComplete: onComplete)
        }
    }
    
    // MARK: - Initialization
    
    typealias Completion = (Result<Balbabe>) -> Void
    let onComplete: Completion
    let email: String
    let password: String
    let balbabeMetadata: BalbabeMetadata
    init(balbabeMetadata: BalbabeMetadata, email: String, password: String, onComplete: @escaping Completion) {
        self.balbabeMetadata = balbabeMetadata
        self.email = email
        self.password = password
        self.onComplete = onComplete
        super.init()
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        Auth.auth().createUser(withEmail: email.lowercased(), password: password) { [weak self] (user, error) in
            guard let strongSelf = self else {
                return
            }
            
            guard let user = user else {
                strongSelf.onComplete(.failure(error))
                strongSelf.state = .finished
                return
            }
            Database.database().reference(withPath: "balbabes/\(user.uid)").setValue(strongSelf.balbabeMetadata.dictionaryRepresentation()) { error, reference in
                if let error = error {
                    strongSelf.onComplete(.failure(error))
                    strongSelf.state = .finished
                    return
                }
                
                let balbabe = Balbabe(id: user.uid, metadata: strongSelf.balbabeMetadata)
                strongSelf.onComplete(.success(balbabe))
                strongSelf.state = .finished
            }
        }
    }
}
