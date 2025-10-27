import UIKit
import ReactiveKit
import DiiaCommonTypes
import DiiaMVPModule
import DiiaUIComponents
import DiiaDocumentsCommonTypes

public final class DocumentsCollectionModule: BaseModule {
    private let view: DocumentsCollectionViewController
    private let presenter: DocumentsCollectionPresenter
    
    public init(context: DocumentsCollectionModuleСontext, holder: DocumentCollectionHolderProtocol) {
        view = DocumentsCollectionViewController.storyboardInstantiate(bundle: Bundle.module)
        view.actionFabric = DocumentActionsFabric()

        let documentsCollectionContext = DocumentsCollectionContextImpl(context: context)
        presenter = DocumentsCollectionPresenter(context: documentsCollectionContext, view: view, holder: holder)

        view.presenter = presenter
    }

    public func viewController() -> UIViewController {
        return view
    }
}

final class DocumentsCollectionContextImpl: DocumentsCollectionContext {
    lazy var documentsLoader: DocumentsLoaderProtocol = context.documentsLoader
    lazy var docProvider: DocumentsProvider = context.docProvider
    lazy var documentsStackRouterCreate: (DocumentAttributesProtocol) -> RouterProtocol = context.documentsStackRouterCreate
    lazy var documentsReorderingConfiguration: DocumentsReorderingConfiguration = context.documentsReorderingConfiguration
    lazy var pushNotificationsSharingSubject: PassthroughSubject<Void, Never> = context.pushNotificationsSharingSubject
    lazy var addDocumentsService: AddDocumentsServiceProtocol = AddDocumentsService(addDocumentsActionProvider: context.addDocumentsActionProvider,
                                                                                    apiClient: AddDocumentAPIClient(context: context.network))

    private let context: DocumentsCollectionModuleСontext

    init(context: DocumentsCollectionModuleСontext) {
        self.context = context
    }
}
