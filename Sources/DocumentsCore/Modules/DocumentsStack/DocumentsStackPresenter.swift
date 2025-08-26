
import UIKit
import DiiaMVPModule
import DiiaDocumentsCommonTypes

protocol DocumentsStackAction: BasePresenter {}

final class DocumentsStackPresenter: NSObject, DocumentsStackAction {
    unowned var view: DocumentsStackView
    private let docType: DocumentAttributesProtocol
    private let docProvider: DocumentsProvider
    private let onDocsStackCollectionAppearsAction: OnDocumentsStackCollectionAppears?
    
    init(view: DocumentsStackView,
         docType: DocumentAttributesProtocol,
         docProvider: DocumentsProvider,
         onDocsStackCollectionAppearsAction: OnDocumentsStackCollectionAppears?) {
        self.view = view
        self.docType = docType
        self.docProvider = docProvider
        self.onDocsStackCollectionAppearsAction = onDocsStackCollectionAppearsAction
    }
    
    func configureView() {
        view.setupChild(module: DocumentsStackCollectionModule(docType: docType,
                                                               holder: self,
                                                               docProvider: docProvider,
                                                               onDocsStackCollectionAppearsAction: onDocsStackCollectionAppearsAction))
        view.setupTitle(title: docType.stackName)
    }
}

extension DocumentsStackPresenter: DocumentCollectionHolderProtocol {
    func updateBackgroundImage(image: UIImage?) {
        view.setBackgroundImage(image: image)
    }
}
