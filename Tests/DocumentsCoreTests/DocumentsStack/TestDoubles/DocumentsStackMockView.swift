
import UIKit
import DiiaMVPModule
@testable import DiiaDocumentsCore

final class DocumentsStackMockView: UIViewController, DocumentsStackView {
    private(set) var isSetupChildCalled = false
    private(set) var isSetupTitleCalled = false
    private(set) var isSetBackgroundImageCalled = false
    
    func setupChild(module: BaseModule) {
        isSetupChildCalled.toggle()
    }
    
    func setupTitle(title: String) {
        isSetupTitleCalled.toggle()
    }
    
    func setBackgroundImage(image: UIImage?) {
        isSetBackgroundImageCalled.toggle()
    }
}
