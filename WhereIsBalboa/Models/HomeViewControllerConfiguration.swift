import Foundation

struct HomeViewControllerConfiguration: Equatable {
    var loggedInBalbabe: Balbabe
    var balbabes: [Balbabe]
    var focusedDate: Date
}

func ==(lhs: HomeViewControllerConfiguration, rhs: HomeViewControllerConfiguration) -> Bool {
    return
        lhs.loggedInBalbabe == rhs.loggedInBalbabe &&
        lhs.balbabes == rhs.balbabes &&
        lhs.focusedDate == rhs.focusedDate
}
