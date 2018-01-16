import MapKit
import FirebaseDatabase
import SwiftyJSON

struct Address: DatabaseConvertible, Equatable {
    private struct DBValues {
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let name = "name"
    }
    
    let location: CLLocation
    let name: String
    
    // MARK: - Init
    
    init(location: CLLocation, name: String) {
        self.location = location
        self.name = name
    }
    
    init?(_ googlePayload: JSON) {
        let locationPayload = googlePayload["geometry"]["location"].dictionaryValue
        guard
            let longitude = locationPayload["lng"]?.double,
            let latitude = locationPayload["lat"]?.double,
            let name = googlePayload["formatted_address"].string
        else {
            return nil
        }
        self.init(location: CLLocation(latitude: latitude, longitude: longitude), name: name)
    }
    
    init(_ dataSnapshot: DataSnapshot) throws {
        guard
            let name = dataSnapshot.childSnapshot(forPath: DBValues.name).value as? String,
            let latitude = dataSnapshot.childSnapshot(forPath: DBValues.latitude).value as? Double,
            let longitude = dataSnapshot.childSnapshot(forPath: DBValues.longitude).value as? Double
        else {
            throw DatabaseConversionError.invalidSnapshot(dataSnapshot)
        }
        self.name = name
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - DatabaseConvertible
    
    func dictionaryRepresentation() -> [String : Any] {
        return [
            DBValues.latitude: location.coordinate.latitude,
            DBValues.longitude: location.coordinate.longitude,
            DBValues.name: name
        ]
    }
}

func ==(lhs: Address, rhs: Address) -> Bool {
    return
        lhs.location.coordinate.latitude == rhs.location.coordinate.latitude &&
        lhs.location.coordinate.longitude == rhs.location.coordinate.longitude &&
        lhs.name == rhs.name
}
