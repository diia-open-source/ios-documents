
import Foundation
import DiiaDocumentsCore

class DocumentsLoaderMock: DocumentsLoaderProtocol {
    private(set) var isUpdateIfNeededCalled = false
    private(set) var isAddListenerCalled = false
    private(set) var isRemoveListenerCalled = false
    
    func updateIfNeeded() {
        isUpdateIfNeededCalled.toggle()
    }
    
    func setNeedUpdates() {}
    
    func removeListener(listener: DocumentsLoadingListenerProtocol) {
        isRemoveListenerCalled.toggle()
    }
    
    func addListener(listener: DocumentsLoadingListenerProtocol) {
        isAddListenerCalled.toggle()
    }
}
