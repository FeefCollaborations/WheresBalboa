import Foundation
import SwiftyJSON

class CitySearchTaskWrapper: AsynchronousOperation, ResultGeneratingOperation {
    enum OperationError: Error {
        case badResponse(JSON)
    }
    
    typealias Completion = (Result<Set<LocationListing>>) -> Void
    let url: URL
    let onComplete: Completion
    
    // MARK: - Init
    
    init?(cityName: String, onComplete: @escaping Completion) {
        guard
            let url = URL(string: "http://ws.geonames.org/searchJSON?name_equals=\(cityName)&featureCode=PPL&username=feef")
        else {
            return nil
        }
        self.url = url
        self.onComplete = onComplete
    }
    
    // MARK: - Superclass overrides
    
    override func start() {
        super.start()
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let strongSelf = self else {
                return
            }
            
            guard let data = data else {
                // TODO: Log error
                strongSelf.onComplete(.failure(error))
                return
            }
            
            do {
                let json = try JSON.init(data: data)
                guard let places = json.dictionaryValue["geonames"]?.array else {
                    // TODO: Log error
                    let error = OperationError.badResponse(json)
                    strongSelf.onComplete(.failure(error))
                    return
                }
                let locationListings = places.flatMap { LocationListing.init($0) }
                strongSelf.onComplete(.success(Set(locationListings)))
            } catch let error {
                // TODO: Log error
                strongSelf.onComplete(.failure(error))
            }
        }
        task.resume()
    }
    
}
