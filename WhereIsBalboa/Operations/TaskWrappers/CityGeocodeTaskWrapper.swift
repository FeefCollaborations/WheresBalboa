import Foundation
import SwiftyJSON

class CityGeocodeTaskWrapper {
    enum SearchError: Error {
        case failedToCreateURL(String), badResponse(JSON)
    }
    
    typealias Completion = (Result<Address>) -> Void
    
    // MARK: - Init
    
    static func geocode(_ cityName: String, onComplete: @escaping Completion) throws -> URLSessionDataTask {
        guard
            let encodedCity = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedCity)&key=AIzaSyBw0XWMwjkhEwlUz8QJEPZ7lY3lAv4rO8I")
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
                guard
                    let foundPlace = json.dictionaryValue["results"]?.array?.first,
                    let locationListing = Address.init(foundPlace)
                else {
                    // TODO: Log error
                    let error = SearchError.badResponse(json)
                    onComplete(.failure(error))
                    return
                }
                onComplete(.success(locationListing))
            } catch let error {
                // TODO: Log error
                onComplete(.failure(error))
            }
        }
    }
}

