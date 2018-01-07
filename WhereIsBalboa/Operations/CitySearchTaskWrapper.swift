import Foundation
import SwiftyJSON

class CitySearchTaskWrapper {
    enum SearchError: Error {
        case failedToCreateURL(String), badResponse(JSON)
    }
    
    typealias Completion = (Result<Set<String>>) -> Void
    
    // MARK: - Init
    
    static func newSearchFor(cityName: String, onComplete: @escaping Completion) throws -> URLSessionDataTask {
        guard
            let encodedCity = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encodedCity)&types=(cities)&key=AIzaSyBw0XWMwjkhEwlUz8QJEPZ7lY3lAv4rO8I")
        else {
            throw SearchError.failedToCreateURL(cityName)
        }
        return URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                // TODO: Log error
                onComplete(.failure(error))
                return
            }
            
            do {
                let json = try JSON.init(data: data)
                guard let places = json.dictionaryValue["predictions"]?.array else {
                    // TODO: Log error
                    let error = SearchError.badResponse(json)
                    onComplete(.failure(error))
                    return
                }
                let locationDescriptions = places.flatMap { $0["description"].string }
                onComplete(.success(Set(locationDescriptions)))
            } catch let error {
                // TODO: Log error
                onComplete(.failure(error))
            }
        }
    }
}
