import Foundation
import CoreLocation
import SwiftyJSON

struct LocationListing {
    let displayText: String
    let address: Address
    
    init?(_ googlePayload: JSON) {
        var addressComponents = [String: String]()
        googlePayload["address_components"].array?.forEach { component in
            component["types"].array?.forEach { type in
                guard
                    let value = component["short_name"].string ?? component["long_name"].string,
                    let typeString = type.string
                else {
                    return
                }
                switch typeString {
                    case "country", "administrative_area_level_1", "locality":
                        addressComponents[typeString] = value
                    default: ()
                }
            }
        }
        let locationPayload = googlePayload["geometry"]["location"].dictionaryValue
        guard
            let longitude = locationPayload["lng"]?.double,
            let latitude = locationPayload["lat"]?.double,
            let city = addressComponents["locality"],
            let state = addressComponents["administrative_area_level_1"],
            let country = addressComponents["country"]
        else {
            return nil
        }
        displayText = city + ", " + state + ", " + country
        let location = CLLocation(latitude: latitude, longitude: longitude)
        address = Address(location: location, city: city, state: state, country: country)
    }
}
