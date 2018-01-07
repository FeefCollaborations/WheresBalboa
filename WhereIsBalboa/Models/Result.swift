import Foundation

enum Result<ResultType> {
    case success(ResultType)
    case failure(Error?)
}
