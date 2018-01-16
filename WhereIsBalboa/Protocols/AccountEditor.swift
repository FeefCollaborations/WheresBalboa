import Foundation

protocol AccountEditor { }

extension AccountEditor {
    func isValid(email: String) -> Bool {
        let components = email.components(separatedBy: CharacterSet(charactersIn: "@."))
        return components.count >= 3 && components.reduce(true, { return $0 && $1.count > 0 })
    }
    
    func isValid(password: String) -> Bool {
        return password.count >= 6
    }
}