import UIKit
import DiiaCommonTypes

public enum DriverLicenseStatus: Int, Codable, EnumDecodable {
    public static let defaultValue: DriverLicenseStatus = .unknown
    
    case ok = 200
    case noPhoto = 1010
    case oldFormat = 1011
    case needVerification = 1012
    case notValid = 1016
    case deposited = 1020
    case destroyed = 1050
    
    case unknown = -1
    
    init(fromRawValue rawValue: Int) {
        self = DriverLicenseStatus(rawValue: rawValue) ?? .unknown
    }
}
