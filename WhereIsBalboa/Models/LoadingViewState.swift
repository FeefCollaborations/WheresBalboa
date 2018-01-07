import Foundation

enum LoadingViewState: Equatable {
    case loading, failed(displayText: String)
}

func ==(lhs: LoadingViewState, rhs: LoadingViewState) -> Bool {
    switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.failed(let lText), .failed(let rText)):
            return lText == rText
        default:
            return false
    }
}
