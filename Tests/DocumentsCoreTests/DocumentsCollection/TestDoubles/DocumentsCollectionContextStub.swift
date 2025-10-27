import UIKit
import ReactiveKit
import DiiaNetwork
import DiiaMVPModule
import DiiaCommonTypes
import DiiaDocumentsCommonTypes
@testable import DiiaDocumentsCore

class DocumentsCollectionContextStub: DocumentsCollectionContext {
    
    let documentsLoader: DocumentsLoaderProtocol
    let docProvider: DocumentsProvider
    
    let documentsStackRouterCreate: (DocumentAttributesProtocol) -> RouterProtocol
    
    var actionFabricAllowedCodes: [DocTypeCode] = []

    let documentsReorderingConfiguration: DocumentsReorderingConfiguration = .init(createReorderingModule: { BaseModuleStub() },
                                                                                   documentsReorderingService: DocumentReorderingServiceStub())
        
    let pushNotificationsSharingSubject: PassthroughSubject<Void, Never>
    
    let addDocumentDescription: String = ""
    
    let addDocumentsService: AddDocumentsServiceProtocol = AddDocumentsServiceStub()
    
    init(documentsLoader: DocumentsLoaderProtocol,
         docProvider: DocumentsProvider,
         documentsStackRouterCreate: @escaping (DocumentAttributesProtocol) -> RouterProtocol,
         pushNotificationsSharingSubject: PassthroughSubject<Void, Never>) {
        self.documentsLoader = documentsLoader
        self.docProvider = docProvider
        self.documentsStackRouterCreate = documentsStackRouterCreate
        self.pushNotificationsSharingSubject = pushNotificationsSharingSubject
    }
    
}

class DocumentReorderingServiceStub: DocumentReorderingServiceProtocol {
    func docTypesOrder() -> [DocTypeCode] {
        return []
    }
    func setOrder(order: [DocTypeCode], synchronize: Bool) {}
    
    func order(for type: DocTypeCode) -> [String] {
        return []
    }
    func setOrder(order: [String], for type: DocTypeCode) { }
    
    func synchronizeIfNeeded() {}
    
    func cleanSynchronized(for type: DocTypeCode) {}
    
    func updateOrdersIfNeeded() {}
}

class AddDocumentsServiceStub: AddDocumentsServiceProtocol {
    func setup(onAdded: @escaping AddDocumentCallback, onExists: @escaping AddDocumentCallback) {}
    
    func showAddDocuments(in view: BaseView, errorCallback: ((NetworkError) -> Void)?) {}
}

class BaseModuleStub: BaseModule {
    func viewController() -> UIViewController {
        return UIViewController()
    }
}
