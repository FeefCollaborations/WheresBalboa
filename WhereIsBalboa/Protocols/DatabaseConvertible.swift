import Foundation
import FirebaseDatabase

protocol DatabaseConvertible {
    func dictionaryRepresentation() -> [String: Any]
}
