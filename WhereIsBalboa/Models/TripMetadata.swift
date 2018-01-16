import UIKit
import FirebaseDatabase

struct TripMetadata: DatabaseConvertible, Equatable {
    private struct DBValues {
        static let address = "address"
        static let dateInterval = "dateInterval"
        static let isHome = "isHome"
    }
    
    let address: Address
    let dateInterval: DateInterval
    let isHome: Bool
    
    init(_ dataSnapshot: DataSnapshot) throws {
        guard
            let isHome = dataSnapshot.childSnapshot(forPath: DBValues.isHome).value as? Bool,
            let dateIntervalString = dataSnapshot.childSnapshot(forPath: DBValues.dateInterval).value as? String,
            let dateInterval = DateInterval(dateIntervalString)
        else {
            throw DatabaseConversionError.invalidSnapshot(dataSnapshot)
        }

        self.isHome = isHome
        self.dateInterval = dateInterval
        address = try Address(dataSnapshot.childSnapshot(forPath: DBValues.address))
    }
    
    init(address: Address, dateInterval: DateInterval, isHome: Bool) {
        self.address = address
        self.dateInterval = dateInterval
        self.isHome = isHome
    }
    
    // MARK: - DatabaseConvertible
    
    func dictionaryRepresentation() -> [String : Any] {
        return [
            DBValues.address: address.dictionaryRepresentation(),
            DBValues.dateInterval: dateInterval.stringRepresentation,
            DBValues.isHome: isHome
        ]
    }
}

func ==(lhs: TripMetadata, rhs: TripMetadata) -> Bool {
    return
        lhs.address == rhs.address &&
        lhs.dateInterval == rhs.dateInterval &&
        lhs.isHome == rhs.isHome
}
