
import UIKit
import DiiaDocumentsCommonTypes

final class DocumentCollectionHolderMock: NSObject, DocumentCollectionHolderProtocol {
    private(set) var isUpdateBackgroundImageCalled = false
    
    func updateBackgroundImage(image: UIImage?) {
        isUpdateBackgroundImageCalled.toggle()
    }
}
