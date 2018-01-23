import Foundation

struct LoginInfo {
    static let delimiter = "*DELIMITER*"
    private static let encoding = String.Encoding.utf8
    
    let email: String
    let password: String
    
    var dataRespresentation: Data? {
        return (email + LoginInfo.delimiter + password).data(using: LoginInfo.encoding)
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    init?(dataRepresentation: Data) {
        guard
            let components = String(data: dataRepresentation, encoding: LoginInfo.encoding)?.components(separatedBy: LoginInfo.delimiter),
            components.count == 2
        else {
            return nil
        }
        self.init(email: components[0], password: components[1])
    }
}
