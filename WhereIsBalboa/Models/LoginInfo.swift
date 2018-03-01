import Foundation

struct LoginInfo {
    static let delimiter = "*DELIMITER*"
    private static let encoding = String.Encoding.utf8
    
    let cohort: Cohort
    let email: String
    let password: String
    
    var dataRespresentation: Data? {
        return (email + LoginInfo.delimiter + password + LoginInfo.delimiter + cohort.rawValue).data(using: LoginInfo.encoding)
    }
    
    init(email: String, password: String, cohort: Cohort) {
        self.email = email
        self.password = password
        self.cohort = cohort
    }
    
    init?(dataRepresentation: Data) {
        guard
            let components = String(data: dataRepresentation, encoding: LoginInfo.encoding)?.components(separatedBy: LoginInfo.delimiter),
            components.count == 3,
            let cohort = Cohort(rawValue: components[2])
        else {
            return nil
        }
        self.init(email: components[0], password: components[1], cohort: cohort)
    }
}

