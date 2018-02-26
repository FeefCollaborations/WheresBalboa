import Foundation
import CoreLocation

enum Cohort: String {
    case balboa
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    static let all: [Cohort] = [.balboa]
    
    var itinerary: [(RYMonth, RYCity)] {
        switch self {
            case .balboa:
                return [
                    (.mar17, .split),
                    (.apr17, .prague),
                    (.may17, .lisbon),
                    (.jun17, .sofia),
                    (.jul17, .belgrade),
                    (.aug17, .valencia),
                    (.sep17, .buenosAires),
                    (.oct17, .córdoba),
                    (.nov17, .lima),
                    (.dec17, .medellin),
                    (.jan18, .bogotá),
                    (.feb18, .mexicoCity)
                ]
        }
    }
    
    var tripMetadatas: [TripMetadata] {
        return itinerary.map { month, city in
            let address = Address(location: city.location, name: city.name)
            return TripMetadata(address: address, dateInterval: month.dateInterval)
        }
    }
}
