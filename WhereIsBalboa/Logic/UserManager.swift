import Foundation
import FirebaseDatabase

class UserManager {
    private(set) var currentUser: Balbabe?
    private var currentObservation: (DatabaseReference, UInt)?
    
    static let shared = UserManager()
    
    func setCurrentUser(_ user: Balbabe?) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if let currentObservation = strongSelf.currentObservation {
                currentObservation.0.removeObserver(withHandle: currentObservation.1)
                strongSelf.currentObservation = nil
            }
            if let user = user {
                let reference: DatabaseReference
                reference = Database.database().reference(withPath: "balbabes/" + user.id)
                let observationID = reference.observe(.value) { (snapshot: DataSnapshot) in
                    do {
                        let updatedUser = try Balbabe(snapshot)
                        guard updatedUser != user else {
                            return
                        }
                        strongSelf.setCurrentUser(updatedUser)
                    } catch {
                        // TODO: Log error
                        return
                    }
                }
                strongSelf.currentObservation = (reference, observationID)
            }
            strongSelf.currentUser = user
            NotificationCenter.default.postUpdatedUserNotification(with: user)
        }
    }
}
