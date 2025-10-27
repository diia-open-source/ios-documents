import Foundation

public protocol StatusedExpirableProtocol: Codable {
    var status: DocumentStatusCode { get }
    var expirationDate: Date { get set }
}
