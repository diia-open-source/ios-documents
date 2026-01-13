
import UIKit
import DiiaMVPModule
@testable import DiiaDocumentsCore

final class BaseMockView: UIViewController, BaseView {
    private(set) var isDocActionSheetModuleCalled = false
    
    func showChild(module: BaseModule) {
        if module is DocumentActionSheetModule {
            isDocActionSheetModuleCalled.toggle()
        }
    }
}
