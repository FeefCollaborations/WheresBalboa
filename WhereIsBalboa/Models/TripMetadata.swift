import UIKit
import FirebaseDatabase

struct TripMetadata: DatabaseConvertible, Equatable {
    private struct DBValues {
        static let startDate = "startTimestamp"
        static let endDate = "endTimestamp"
    }
    
    let address: Address
    var dateInterval: DateInterval {
        return DateInterval(dateIntervalString)!
    }
    let isHome: Bool
    let dateIntervalString: String
    
    init(_ dataSnapshot: DataSnapshot) throws {
        guard
            let startTimestamp = dataSnapshot.childSnapshot(forPath: DBValues.startDate).value as? TimeInterval,
            let endTimestamp = dataSnapshot.childSnapshot(forPath: DBValues.endDate).value as? TimeInterval
        else {
            throw DatabaseConversionError.invalidSnapshot(dataSnapshot)
        }
        
        let dateInterval = DateInterval(start: Date(timeIntervalSince1970: startTimestamp), end: Date(timeIntervalSince1970: endTimestamp))
        self.init(address: try Address(dataSnapshot), dateInterval: dateInterval)
    }
    
    init(address: Address, dateInterval: DateInterval, isHome: Bool = false) {
        self.address = address
        self.dateIntervalString = dateInterval.stringRepresentation
        self.isHome = isHome
    }
    
    // MARK: - DatabaseConvertible
    
    func dictionaryRepresentation() -> [String : Any] {
        var dictionary = address.dictionaryRepresentation()
        dictionary[DBValues.startDate] = dateInterval.start.timeIntervalSince1970
        dictionary[DBValues.endDate] = dateInterval.end.timeIntervalSince1970
        return dictionary
    }
}

func ==(lhs: TripMetadata, rhs: TripMetadata) -> Bool {
    return
        lhs.address == rhs.address &&
        lhs.dateInterval == rhs.dateInterval &&
        lhs.isHome == rhs.isHome
}
