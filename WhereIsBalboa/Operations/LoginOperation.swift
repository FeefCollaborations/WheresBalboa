import Foundation
import FirebaseAuth
import FirebaseDatabase

class LoginOperation: AsynchronousOperation, ResultGeneratingOperation {
    
    // MARK: - Initialization
    
    typealias Completion = (Result<Balbabe>) -> Void
    let onComplete: Completion
    let loginInfo: LoginInfo
    init(_ loginInfo: LoginInfo, onComplete: @escaping Completion) {
        self.onComplete = onComplete
        self.loginInfo = loginInfo
        super.init()
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        Auth.auth().signIn(withEmail: loginInfo.email, password: loginInfo.password) { [weak self] user, error in
            guard let strongSelf = self else {
                return
            }
            
            guard let user = user else {
                strongSelf.onComplete(.failure(error))
                strongSelf.state = .finished
                return
            }
            
            Database.database().reference(withPath: "balbabes/\(user.uid)").observeSingleEvent(of: .value) { snapshot in
                DispatchQueue.main.async {
                    do {
                        let balbabe = try Balbabe(snapshot)
                        strongSelf.onComplete(.success(balbabe))
                        strongSelf.state = .finished
                    } catch let error {
                        strongSelf.onComplete(.failure(error))
                        strongSelf.state = .finished
                    }
                }
            }
        }
    }
}

