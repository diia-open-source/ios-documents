import Foundation
import DiiaMVPModule
import DiiaDocumentsCommonTypes
import DiiaDocumentsCore

class DocumentsProviderMock: DocumentsProvider {
    let documents: [DocumentModel]
    
    init(documents: [DocumentModel]) {
        self.documents = documents
    }
    
    func documents(with order: [DocTypeCode], actionView: BaseView?) -> [MultiDataType<DocumentModel>] {
        if documents.count == 1 {
            return [.single(documents[.zero])]
        }
        
        return [.multiple(documents)]
    }
}
