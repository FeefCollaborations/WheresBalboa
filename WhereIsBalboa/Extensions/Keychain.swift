import Foundation
import KeychainAccess

extension Keychain {
    private static let loginInfoKey = "loginInfo"
    
    static let standard: Keychain = Keychain()
    
    func setLoginInfo(_ loginInfo: LoginInfo?) {
        guard let loginInfo = loginInfo else {
            try? remove(Keychain.loginInfoKey)
            return
        }
        
        guard let data = loginInfo.dataRespresentation else {
            // TODO: Log error
            return
        }
        try? set(data, key: Keychain.loginInfoKey)
    }
    
    func getLoginInfo() -> LoginInfo? {
        do {
            guard
                let data = try getData(Keychain.loginInfoKey),
                let loginInfo = LoginInfo(dataRepresentation: data)
            else {
                return nil
            }
            return loginInfo
        } catch {
            return nil
        }
    }
}
