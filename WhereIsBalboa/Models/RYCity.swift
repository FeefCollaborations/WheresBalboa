import Foundation
import CoreLocation

enum RYCity {
    case split, prague, lisbon, sofia, belgrade, valencia, buenosAires, córdoba, lima, medellin, bogotá, mexicoCity
    
    var name: String {
        switch self {
            case .split:
                return "Splitska, Croatia"
            case .prague:
                return "Prague, Czechia"
            case .lisbon:
                return "Lisbon, Portugal"
            case .sofia:
                return "Sofia, Bulgaria"
            case .belgrade:
                return "Belgrade, Serbia"
            case .valencia:
                return "Valencia, Spain"
            case .buenosAires:
                return "Buenos Aires, Argentina"
            case .córdoba:
                return "Córdoba, Cordoba, Argentina"
            case .lima:
                return "Lima, Peru"
            case .medellin:
                return "Medellin, Antioquia, Colombia"
            case .bogotá:
                return "Bogotá, Bogota, Colombia"
            case .mexicoCity:
                return "Mexico City, CDMX, Mexico"
        }
    }
    
    var location: CLLocation {
        switch self {
            case .split:
                return CLLocation(latitude: 43.374850199999997, longitude: 16.6056493)
            case .prague:
                return CLLocation(latitude: 50.075538100000003, longitude: 14.4378005)
            case .lisbon:
                return CLLocation(latitude: 38.722252400000002, longitude: -9.1393366)
            case .sofia:
                return CLLocation(latitude: 42.697708200000001, longitude: 23.3218675)
            case .belgrade:
                return CLLocation(latitude: 44.786568000000003, longitude: 20.448921599999998)
            case .valencia:
                return CLLocation(latitude: 39.469907499999998, longitude: -0.37628810000000001)
            case .buenosAires:
                return CLLocation(latitude: -34.603684399999999, longitude: -58.381559099999997)
            case .córdoba:
                return CLLocation(latitude: -31.420083299999991, longitude: -64.188776099999998)
            case .lima:
                return CLLocation(latitude: -12.0463731, longitude: -77.042754000000002)
            case .medellin:
                return CLLocation(latitude: 6.2442029999999997, longitude: -75.5812119)
            case .bogotá:
                return CLLocation(latitude: 4.7109885999999994, longitude: -74.072091999999998)
            case .mexicoCity:
                return CLLocation(latitude: 19.432607699999998, longitude: -99.133207999999996)
        }
    }
}
