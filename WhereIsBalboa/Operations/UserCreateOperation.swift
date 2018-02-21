import Foundation
import FirebaseAuth
import FirebaseDatabase

class UserCreateOperation: AsynchronousOperation, ResultGeneratingOperation {
    struct Builder {
        var name: String?
        var hometown: Address?
        var whatsapp: String?
        var loginInfo: LoginInfo?
        
        func build(onComplete: @escaping Completion) throws -> UserCreateOperation {
            guard
                let name = name,
                let hometown = hometown,
                let whatsapp = whatsapp,
                let loginInfo = loginInfo
            else {
                throw OperationBuilderError.missingValues
            }
            let balbabeMetadata = try UserMetadata(name: name, whatsapp: whatsapp, hometown: hometown)
            return UserCreateOperation(balbabeMetadata: balbabeMetadata, loginInfo: loginInfo, onComplete: onComplete)
        }
    }
    
    // MARK: - Initialization
    
    typealias Completion = (Result<User>) -> Void
    let onComplete: Completion
    let loginInfo: LoginInfo
    let balbabeMetadata: UserMetadata
    init(balbabeMetadata: UserMetadata, loginInfo: LoginInfo, onComplete: @escaping Completion) {
        self.balbabeMetadata = balbabeMetadata
        self.loginInfo = loginInfo
        self.onComplete = onComplete
        super.init()
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        Auth.auth().createUser(withEmail: loginInfo.email.lowercased(), password: loginInfo.password) { [weak self] (user, error) in
            guard let strongSelf = self else {
                return
            }
            
            guard let user = user else {
                strongSelf.onComplete(.failure(error))
                strongSelf.state = .finished
                return
            }
            Database.database().reference(withPath: strongSelf.loginInfo.cohort.rawValue + "/users/" + user.uid).setValue(strongSelf.balbabeMetadata.dictionaryRepresentation()) { error, reference in
                if let error = error {
                    strongSelf.onComplete(.failure(error))
                    strongSelf.state = .finished
                    return
                }
                
                let balbabe = User(id: user.uid, metadata: strongSelf.balbabeMetadata)
                strongSelf.onComplete(.success(balbabe))
                strongSelf.state = .finished
            }
        }
    }
}
