import UIKit

enum TripViewType: Equatable {
    case loading(LoadingViewController), map(TripMapViewController), list(TripListTableViewController)
    
    var viewController: UIViewController {
        switch self {
            case .map(let viewController):
                return viewController
            case .list(let viewController):
                return viewController
            case .loading(let viewController):
                return viewController
        }
    }
    
    var isLoading: Bool {
        switch self {
            case .loading:
                return true
            case .list, .map:
                return false
        }
    }
}

func ==(lhs: TripViewType, rhs: TripViewType) -> Bool {
    switch (lhs, rhs) {
        case (.map(let vc1), .map(let vc2)):
            return vc1 == vc2
        case (.list(let vc1), .list(let vc2)):
            return vc1 == vc2
        case (.loading(let vc1), .loading(let vc2)):
            return vc1 == vc2
        default:
            return false
    }
}
