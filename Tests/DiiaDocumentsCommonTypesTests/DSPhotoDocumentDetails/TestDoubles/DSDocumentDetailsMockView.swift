import UIKit
import DiiaUIComponents
@testable import DiiaDocumentsCommonTypes

class DSDocumentDetailsMockView: UIViewController, DSDocumentDetailsView {
    private(set) var isSetupCalled = false
    
    func setup(with viewModel: DocumentViewModel, insuranceTicker: DSTickerAtom?) {
        isSetupCalled.toggle()
    }
    
}
