
import Foundation

public struct CodedNamedValueModel: Codable {
    public let code: String?
    public let name: String
    public let value: String
    
    public init(code: String?, name: String, value: String) {
        self.code = code
        self.name = name
        self.value = value
    }
}

public struct NamedValueModel: Codable {
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

// MARK: - Localisation
public enum LocalizationType: String, Codable {
    case en = "eng"
    case ua
}
