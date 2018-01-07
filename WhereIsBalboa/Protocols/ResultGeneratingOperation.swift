import Foundation

protocol ResultGeneratingOperation {
    associatedtype ResultType
    var onComplete: (Result<ResultType>) -> Void { get }
}
