
import UIKit
import DiiaMVPModule
@testable import DiiaDocumentsCore

class DocumentsCollectionMockView: UIViewController, DocumentsCollectionView {
    
    private(set) var isUpdateDocumentsCalled: Bool = false
    private(set) var isSetStatusTextCalled: Bool = false
    private(set) var isFlipCurrentItemCalled: Bool = false
    private(set) var isScrollCalled: Bool = false
    private(set) var isOnSharingRequestReceived = false
    private(set) var isDocumentsStackModuleCalled = false
    private(set) var isCloseModuleCalled: Bool = false
    
    func updateDocuments() {
        isUpdateDocumentsCalled.toggle()
    }
    
    func setStatusText(statusText: String?) {
        isSetStatusTextCalled.toggle()
    }
    
    func scroll(to indexPath: IndexPath, animated: Bool) {
        isScrollCalled.toggle()
    }
    
    func onSharingRequestReceived() {
        isOnSharingRequestReceived.toggle()
    }
    
    func flipCurrentItem() {
        isFlipCurrentItemCalled.toggle()
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func open(module: BaseModule) {
        if module is DocumentsStackModule {
            isDocumentsStackModuleCalled.toggle()
        }
    }
    
    func closeModule(animated: Bool) {
        isCloseModuleCalled.toggle()
    }
}

