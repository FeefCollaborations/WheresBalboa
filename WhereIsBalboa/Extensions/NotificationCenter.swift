import Foundation

extension NotificationCenter {
    @discardableResult func registerForUserChanges(onChange: @escaping (Balbabe?) -> Void) -> NSObjectProtocol {
        return addObserver(forName: .updatedUser, object: nil, queue: nil, using: { notification in
            guard let user = notification.updatedUser else {
                return
            }
            onChange(user)
        })
    }
    
    func postUpdatedUserNotification(with updatedUser: Balbabe?) {
        let userInfo: [AnyHashable: Any]?
        if let user = updatedUser {
            userInfo = [userUserInfoKey: user]
        } else {
            userInfo = nil
        }
        post(name: .updatedUser, object: nil, userInfo: userInfo)
    }
}

fileprivate let userUserInfoKey = "updatedUser"
fileprivate let userNotificationName = "updatedUser"

fileprivate extension Notification {
    var updatedUser: Balbabe? {
        return userInfo?[userUserInfoKey] as? Balbabe
    }
}

fileprivate extension Notification.Name {
    static let updatedUser = Notification.Name(userNotificationName)
}
