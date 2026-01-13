
import Foundation

public protocol DocumentsLoaderProtocol {
    func updateIfNeeded()
    func setNeedUpdates()
    func removeListener(listener: DocumentsLoadingListenerProtocol)
    func addListener(listener: DocumentsLoadingListenerProtocol)
}

@objc public protocol DocumentsLoadingListenerProtocol {
    func documentsWasUpdated()
    func secondaryDocumentsWasUpdated()
}
