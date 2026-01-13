
import Foundation
import DiiaDocumentsCommonTypes

public protocol DocumentReorderingServiceProtocol {
    func docTypesOrder() -> [DocTypeCode]
    func setOrder(order: [DocTypeCode], synchronize: Bool)
    func order(for type: DocTypeCode) -> [String]
    func setOrder(order: [String], for type: DocTypeCode)
    func synchronizeIfNeeded()
    func cleanSynchronized(for type: DocTypeCode)
    func updateOrdersIfNeeded()
}
