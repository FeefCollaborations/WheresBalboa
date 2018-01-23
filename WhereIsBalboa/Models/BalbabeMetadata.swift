import Foundation
import CoreLocation
import FirebaseDatabase

struct BalbabeMetadata: Equatable, DatabaseConvertible {
    enum InitializationError: Error {
        case invalidWhatsapp(String)
    }
    
    private struct DBValues {
        static let name = "name"
        static let whatsapp = "whatsapp"
        static let hometown = "hometown"
    }
    
    let name: String
    let whatsapp: String
    let hometown: Address
    let whatsappURL: URL
    
    init(_ dataSnapshot: DataSnapshot) throws {
        guard
            let name = dataSnapshot.childSnapshot(forPath: "name").value as? String,
            let whatsapp = dataSnapshot.childSnapshot(forPath: "whatsapp").value as? String
        else {
            throw DatabaseConversionError.invalidSnapshot(dataSnapshot)
        }
        let hometown = try Address(dataSnapshot.childSnapshot(forPath: "hometown"))
        try self.init(name: name, whatsapp: whatsapp, hometown: hometown)
    }
    
    init(name: String, whatsapp: String, hometown: Address) throws {
        var urlReadyNumber = whatsapp.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
        guard urlReadyNumber.count > 3 else {
            throw InitializationError.invalidWhatsapp(whatsapp)
        }
        let leadingZeroes = "00"
        let leadingZerosCheckEndIndex = urlReadyNumber.index(urlReadyNumber.startIndex, offsetBy: leadingZeroes.count)
        if urlReadyNumber[urlReadyNumber.startIndex..<leadingZerosCheckEndIndex] == leadingZeroes {
            urlReadyNumber = String(urlReadyNumber[leadingZerosCheckEndIndex..<urlReadyNumber.endIndex])
        }
        guard let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=" + urlReadyNumber) else {
            throw InitializationError.invalidWhatsapp(urlReadyNumber)
        }
        
        self.name = name
        self.whatsapp = whatsapp
        self.hometown = hometown
        self.whatsappURL = whatsappURL
    }
    
    func dictionaryRepresentation() -> [String : Any] {
        return [
            DBValues.name: name,
            DBValues.whatsapp: whatsapp,
            DBValues.hometown: hometown.dictionaryRepresentation()
        ]
    }
}

func ==(lhs: BalbabeMetadata, rhs: BalbabeMetadata) -> Bool {
    return
        lhs.name == rhs.name &&
        lhs.whatsapp == rhs.whatsapp &&
        lhs.hometown == rhs.hometown
}

