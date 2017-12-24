import Foundation
import CoreLocation

struct Balbabe: Equatable {
    typealias ID = String
    
    let id: ID
    let name: String
    let whatsapp: String?
    let hometown: CLLocation?
    let trips: [Trip]
    
    private static var dummyID = "|"
    private static func dummyHometown() -> CLLocation {
        let randomLat = Double(arc4random_uniform(18000)) / 100
        let randomLon = Double(arc4random_uniform(18000)) / 100
        return CLLocation(latitude: randomLat - 90, longitude: randomLon - 90)
    }
    static func dummy() -> Balbabe {
        let balbabe = Balbabe(id: dummyID, name: "Balbabe", whatsapp: "+61414491231", hometown: dummyHometown(), trips: [.dummy(), .dummy(), .dummy(), .dummy(), .dummy(), .dummy()])
        dummyID += "|"
        return balbabe
    }
}

func ==(lhs: Balbabe, rhs: Balbabe) -> Bool {
    return
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.whatsapp == rhs.whatsapp &&
        lhs.hometown == rhs.hometown &&
        lhs.trips == rhs.trips
}
