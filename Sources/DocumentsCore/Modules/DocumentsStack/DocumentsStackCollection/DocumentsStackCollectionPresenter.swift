
import UIKit
import DiiaDocumentsCommonTypes

public typealias OnDocumentsStackCollectionAppears = (_ code: DocTypeCode) -> Void

final class DocumentsStackCollectionPresenter: DocumentsCollectionAction {
    
    // MARK: - Properties
    unowned var view: DocumentsCollectionView
    private unowned let holder: DocumentCollectionHolderProtocol
    
    private let docType: DocumentAttributesProtocol
    private var documents: [DocumentModel] = []
    private let documentsProvider: DocumentsProvider
    private let onDocsStackCollectionAppearsAction: OnDocumentsStackCollectionAppears?

    var haveAdditionalCard: Bool {
        return false
    }

    // MARK: - Init
    init(view: DocumentsCollectionView,
         docType: DocumentAttributesProtocol,
         holder: DocumentCollectionHolderProtocol,
         documentsProvider: DocumentsProvider,
         onDocsStackCollectionAppearsAction: OnDocumentsStackCollectionAppears?) {
        self.view = view
        self.docType = docType
        self.holder = holder
        self.documentsProvider = documentsProvider
        self.onDocsStackCollectionAppearsAction = onDocsStackCollectionAppearsAction

        processDocuments()
        configureObserving()
    }
    
    private func configureObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(documentsWasUpdated),
                                               name: DocumentsConstants.Notifications.documentsWasReordered,
                                               object: nil)
    }
    
    func configureView() {
        self.view.updateDocuments()
    }
    
    private func processDocuments() {
        self.documents = documentsProvider.documents(with: [docType.docCode], actionView: view).first?.getValues() ?? []
    }
    
    func checkReachability() {}
    
    @objc func documentsWasUpdated() {
        processDocuments()
        view.updateDocuments()
        if documents.count <= 1 {
            view.closeModule(animated: true)
        }
    }
    
    func viewDidAppear() {
        onDocsStackCollectionAppearsAction?(docType.docCode)
    }
    
    func numberOfItems() -> Int {
        return documents.count
    }
    
    func itemAtIndex(index: Int) -> MultiDataType<DocumentModel>? {
        if documents.indices.contains(index) {
            return .single(documents[index])
        }
        return nil
    }

    func selectItem(index: Int) {
        guard let item = itemAtIndex(index: index) else { return }
        switch item {
        case .single:
            view.flipCurrentItem()
        case .multiple:
            if let type = item.getValue().docType {
                view.open(module: DocumentsStackModule(docType: type,
                                                       docProvider: documentsProvider,
                                                       onDocsStackCollectionAppearsAction: onDocsStackCollectionAppearsAction))
            }
        }
	}
    
    func processAction(action: String) {}
    
    func updateBackgroundImage(image: UIImage?) {
        holder.updateBackgroundImage(image: image)
    }
    
    func stackClicked(at index: Int) {}
}
