
import Foundation
import DiiaMVPModule
import DiiaDocumentsCommonTypes

public protocol DocumentsProvider {
    func documents(with order: [DocTypeCode], actionView: BaseView?) -> [MultiDataType<DocumentModel>]
}
