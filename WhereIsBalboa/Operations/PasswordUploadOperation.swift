import Foundation
import FirebaseDatabase
import SwiftyJSON

class PasswordUploadOperation: Operation {
    private let dictionary: [String: [String: String]]
    init(fileName: String = "userPasswords") {
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
        let text = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let json = JSON(parseJSON: text)
        dictionary = json.dictionaryObject as! [String: [String: String]]
    }
    
    override func start() {
        super.start()
        let updatedDictionary = dictionary.reduce([String: [String: String]]()) { aggregate, entry in
            let (key, value) = entry
            var updated = aggregate
            guard
                let cohortString = value["cohort"],
                Cohort(rawValue: cohortString) == nil
            else {
                updated[key] = value
                return updated
            }
            var updatedValue = value
            updatedValue["cohort"] = nil
            updated[key] = updatedValue
            return updated
        }
        let ref = Database.database().reference(withPath: "signUpCodes")
        ref.updateChildValues(updatedDictionary)
    }
}
