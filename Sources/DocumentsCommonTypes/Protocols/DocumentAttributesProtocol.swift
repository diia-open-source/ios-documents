
import Foundation

/// the string value of DocType (must be declared on the app level)
public typealias DocTypeCode = String

public struct WarningModel {
    public let title: String
    public let description: String
    
    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

public enum VerificationType {
    case qr
    case barcode
}

public protocol DocumentAttributesProtocol {
    var docCode: DocTypeCode { get }
    var name: String { get }
    var stackName: String { get }
    var faqCategoryId: String { get }
    func warningModel() -> WarningModel?
    var stackIconAppearance: DocumentStackIconAppearance { get }
    var isStaticDoc: Bool { get }
    func isDocCodeSameAs(otherDocCode: DocTypeCode) -> Bool
}
