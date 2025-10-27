import UIKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaUIComponents
import DiiaDocumentsCommonTypes

final class DocumentsStackModule: BaseModule {
    private let view: DocumentsStackViewController
    private let presenter: DocumentsStackPresenter
    
    init(docType: DocumentAttributesProtocol,
         docProvider: DocumentsProvider,
         onDocsStackCollectionAppearsAction: OnDocumentsStackCollectionAppears?) {
        view = DocumentsStackViewController.storyboardInstantiate(bundle: Bundle.module)
        presenter = DocumentsStackPresenter(view: view,
                                            docType: docType,
                                            docProvider: docProvider,
                                            onDocsStackCollectionAppearsAction: onDocsStackCollectionAppearsAction)
        view.presenter = presenter
    }

    func viewController() -> UIViewController {
        return view
    }
}

public final class DocumentsStackRouter: RouterProtocol {
    private let docType: DocumentAttributesProtocol
    private let docProvider: DocumentsProvider
    private let onDocsStackCollectionAppearsAction: OnDocumentsStackCollectionAppears?

    public init(docType: DocumentAttributesProtocol,
                docProvider: DocumentsProvider,
                onDocsStackCollectionAppearsAction: OnDocumentsStackCollectionAppears? = nil) {
        self.docType = docType
        self.docProvider = docProvider
        self.onDocsStackCollectionAppearsAction = onDocsStackCollectionAppearsAction
    }

    public func route(in view: BaseView) {
        view.open(module: DocumentsStackModule(docType: docType,
                                               docProvider: docProvider,
                                               onDocsStackCollectionAppearsAction: onDocsStackCollectionAppearsAction))
    }
}
