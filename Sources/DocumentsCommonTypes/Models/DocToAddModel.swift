import Foundation

// MARK: - DocsToAddModel
public struct AllDocsToAdd: Decodable {
    public let documents: [DocsToAddModel]
}

public struct DocsToAddModel: Decodable {
    // ex-DocsToAddCode enum, add a validation in places where cases of this enum are used, if need
    public let code: String
    public let name: String
    
    public init(code: String, name: String) {
        self.code = code
        self.name = name
    }
}
