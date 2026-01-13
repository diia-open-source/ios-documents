
import UIKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaDocumentsCommonTypes

final class DocumentsStackCollectionModule: BaseModule {
    private let view: DocumentsCollectionViewController
    private let presenter: DocumentsStackCollectionPresenter
    
    init(docType: DocumentAttributesProtocol,
         holder: DocumentCollectionHolderProtocol,
         docProvider: DocumentsProvider,
         onDocsStackCollectionAppearsAction: OnDocumentsStackCollectionAppears?) {
        view = DocumentsCollectionViewController.storyboardInstantiate(bundle: Bundle.module)
        view.actionFabric = DocumentStackActionsFabric()
        presenter = DocumentsStackCollectionPresenter(view: view,
                                                      docType: docType,
                                                      holder: holder,
                                                      documentsProvider: docProvider,
                                                      onDocsStackCollectionAppearsAction: onDocsStackCollectionAppearsAction)
        view.presenter = presenter
    }

    func viewController() -> UIViewController {
        return view
    }
}
