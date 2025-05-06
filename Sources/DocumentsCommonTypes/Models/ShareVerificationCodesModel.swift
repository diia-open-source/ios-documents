
import Foundation
import DiiaUIComponents

public struct ShareVerificationCodesModel: Decodable {
    public let verificationCodesOrg: DSVerificationCodesModel?
    
    public init(verificationCodesOrg: DSVerificationCodesModel?) {
        self.verificationCodesOrg = verificationCodesOrg
    }
}
