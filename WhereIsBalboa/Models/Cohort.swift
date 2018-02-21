import Foundation

enum Cohort: String {
    case balboa
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    static let all: [Cohort] = [.balboa]
}
