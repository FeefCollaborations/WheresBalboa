import Foundation

enum HomeViewControllerState: Equatable {
    case loading, populated(userManager: UserManager, trips: [Trip], focusedDate: Date)
}

func ==(lhs: HomeViewControllerState, rhs: HomeViewControllerState) -> Bool {
    switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.populated(let um1, let t1, let fd1), .populated(let um2, let t2, let fd2)):
            return um1 == um2 && t1 == t2 && fd1 == fd2
        default:
            return false
    }
}
