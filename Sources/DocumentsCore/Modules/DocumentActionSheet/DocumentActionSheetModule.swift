
import Foundation
import UIKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaCommonTypes
import DiiaDocumentsCommonTypes

final class DocumentActionSheetModule: BaseModule {
    private let view: DocumentActionSheetViewController
    
    init(actions: [[Action]], codeAction: ((VerificationType) -> Void)?) {
        view = DocumentActionSheetViewController()
        view.codeAction = codeAction
        view.actions = actions
    }
    
    public func viewController() -> UIViewController {
        let vc = ChildContainerViewController()
        vc.childSubview = view
        vc.presentationStyle = .actionSheet
        return vc
    }
}
