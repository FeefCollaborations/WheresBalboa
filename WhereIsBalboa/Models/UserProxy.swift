import Foundation
import FirebaseDatabase

struct UserProxy {
    let name: String
    let cohort: Cohort?
    
    init(name: String, cohort: Cohort?) {
        self.name = name
        self.cohort = cohort
    }
    
    init(_ snapshot: DataSnapshot) throws {
        guard let name = snapshot.childSnapshot(forPath: "name").value as? String else {
            throw DatabaseConversionError.invalidSnapshot(snapshot)
        }
        let cohort: Cohort?
        if let cohortString = snapshot.childSnapshot(forPath: "cohort").value as? String {
            cohort = Cohort(rawValue: cohortString)
        } else {
            cohort = nil
        }
        self.init(name: name, cohort: cohort)
    }
}
