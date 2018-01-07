import UIKit

struct TripMetadata: Equatable {
    let address: Address
    let dateInterval: DateInterval
    let isHome: Bool
}

func ==(lhs: TripMetadata, rhs: TripMetadata) -> Bool {
    return
        lhs.address == rhs.address &&
        lhs.dateInterval == rhs.dateInterval &&
        lhs.isHome == rhs.isHome
}
