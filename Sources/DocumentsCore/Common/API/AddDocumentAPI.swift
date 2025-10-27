import Foundation
import DiiaNetwork

enum AddDocumentAPI: CommonService {
    static var host: String = ""
    static var headers: [String: String]?

    case getDocsToAdd
    
    var timeoutInterval: TimeInterval {
        return 30
    }
    
    var host: String {
        return AddDocumentAPI.host
    }
    
    var headers: [String: String]? {
        return AddDocumentAPI.headers
    }
    
    var method: HTTPMethod {
        switch self {
        case .getDocsToAdd:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getDocsToAdd:
            return "v1/documents/manual"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getDocsToAdd:
            return nil
        }
    }
    
    var analyticsName: String {
        switch self {
        case .getDocsToAdd:
            return NetworkActionKey.getDocsToAdd.rawValue
        }
    }
    
    public var analyticsAdditionalParameters: String? { return nil }
}

private enum NetworkActionKey: String {
    case getDocsToAdd
}
