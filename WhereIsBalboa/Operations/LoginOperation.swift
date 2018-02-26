import Foundation
import FirebaseAuth
import FirebaseDatabase

class LoginOperation: AsynchronousOperation, ResultGeneratingOperation {
    enum LoginError: Error {
        case userMustCreateAccount(UserProxy)
    }
    
    // MARK: - Initialization
    
    typealias Completion = (Result<(User, Cohort)>) -> Void
    let onComplete: Completion
    let signUpCode: String
    init(_ signUpCode: String, onComplete: @escaping Completion) {
        self.onComplete = onComplete
        self.signUpCode = signUpCode
        super.init()
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        Auth.auth().signInAnonymously { [weak self] user, error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                strongSelf.onComplete(.failure(error))
                strongSelf.state = .finished
                return
            }
            
            Database.database().reference(withPath: "signUpCodes/" + strongSelf.signUpCode).observeSingleEvent(of: .value) { snapshot in
                do {
                    let userProxy = try UserProxy(snapshot)
                    if let cohort = userProxy.cohort {
                        Database.database().reference(withPath: cohort.rawValue + "/users/" + strongSelf.signUpCode).observeSingleEvent(of: .value) { snapshot in
                            do {
                                let user = try User(snapshot)
                                strongSelf.onComplete(.success((user, cohort)))
                                strongSelf.state = .finished
                            } catch {
                                strongSelf.onComplete(.failure(LoginError.userMustCreateAccount(userProxy)))
                                strongSelf.state = .finished
                            }
                        }
                    } else {
                        // User must be signing up
                        strongSelf.onComplete(.failure(LoginError.userMustCreateAccount(userProxy)))
                        strongSelf.state = .finished
                    }
                } catch let error {
                    strongSelf.onComplete(.failure(error))
                    strongSelf.state = .finished
                }
            }
        }
    }
}

