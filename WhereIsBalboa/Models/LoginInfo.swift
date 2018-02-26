import Foundation

struct LoginInfo {
    static let delimiter = "*DELIMITER*"
    private static let encoding = String.Encoding.utf8
    
    let cohort: Cohort
    let signUpCode: String
    
    var dataRespresentation: Data? {
        return (signUpCode + LoginInfo.delimiter + cohort.rawValue).data(using: LoginInfo.encoding)
    }
    
    init(signUpCode: String, cohort: Cohort) {
        self.signUpCode = signUpCode
        self.cohort = cohort
    }
    
    init?(dataRepresentation: Data) {
        guard
            let components = String(data: dataRepresentation, encoding: LoginInfo.encoding)?.components(separatedBy: LoginInfo.delimiter),
            components.count == 2,
            let cohort = Cohort(rawValue: components[1])
        else {
            return nil
        }
        self.init(signUpCode: components[0], cohort: cohort)
    }
}
