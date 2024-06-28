import Foundation
import CommonCrypto

class BBBAPI {
    let serverURL: String
    let sharedSecret: String
    
    init(serverURL: String, sharedSecret: String) {
        self.serverURL = serverURL
        self.sharedSecret = sharedSecret
    }
    
    func generateChecksum(_ query: String) -> String {
        let data = "\(query)\(sharedSecret)".data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func joinMeeting(joinURL: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: joinURL) else {
            completion(nil)
            return
        }
        
        completion(url)
    }
}
