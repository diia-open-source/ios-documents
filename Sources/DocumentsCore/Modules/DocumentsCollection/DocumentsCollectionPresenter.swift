import UIKit
import ReactiveKit
import DiiaCommonTypes
import DiiaMVPModule
import DiiaCommonServices
import DiiaDocumentsCommonTypes

protocol DocumentsCollectionContext {
    var documentsLoader: DocumentsLoaderProtocol { get }
    var docProvider: DocumentsProvider { get }
    var documentsStackRouterCreate: (DocumentAttributesProtocol) -> RouterProtocol { get }
    var documentsReorderingConfiguration: DocumentsReorderingConfiguration { get }
    var pushNotificationsSharingSubject: PassthroughSubject<Void, Never> { get }
    var addDocumentsService: AddDocumentsServiceProtocol { get }
}

protocol DocumentsCollectionAction: BasePresenter {
    func checkReachability()
    func viewDidAppear()
    func numberOfItems() -> Int
    func itemAtIndex(index: Int) -> MultiDataType<DocumentModel>?
    func selectItem(index: Int)
    func processAction(action: String)
    func updateBackgroundImage(image: UIImage?)
    func stackClicked(at index: Int)
    var haveAdditionalCard: Bool { get }
}

final class DocumentsCollectionPresenter: DocumentsCollectionAction, DocumentsLoadingListenerProtocol {
    unowned var view: DocumentsCollectionView
    private unowned let holder: DocumentCollectionHolderProtocol
    private let context: DocumentsCollectionContext

    private var documents: [MultiDataType<DocumentModel>] = []
    private var scrollingDocType: DocTypeCode?

    private let bag = DisposeBag()

    init(context: DocumentsCollectionContext, view: DocumentsCollectionView, holder: DocumentCollectionHolderProtocol) {
        self.view = view
        self.holder = holder
        self.context = context

        setupAddDocumentsService()
    }

    private func observeSharingRequest() {
        context.pushNotificationsSharingSubject
            .observeNext { [weak self] _ in
                guard let self = self else { return }
                self.view.onSharingRequestReceived()
            }
            .dispose(in: bag)
    }
    
    func configureView() {
        ReachabilityHelper.shared
            .statusSignal
            .observeNext { [weak self] isReachable in self?.onNetworkStatus(isReachable: isReachable) }
            .dispose(in: bag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(documentsWasUpdated), name: DocumentsConstants.Notifications.documentsWasReordered, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(documentsModeWasSwitched(notification:)), name: DocumentsConstants.Notifications.documentsModeWasSwitched, object: nil)
        context.documentsLoader.addListener(listener: self)

        observeSharingRequest()
        processDocuments()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        context.documentsLoader.removeListener(listener: self)
    }
    
    func viewDidAppear() {
        context.documentsLoader.updateIfNeeded()
        scrollDocIfNeeded()
    }
    
    func checkReachability() {
        let isReachable = ReachabilityHelper.shared.isReachable()
        onNetworkStatus(isReachable: isReachable)
    }
    
    @objc func documentsWasUpdated() {
        processDocuments()
        scrollDocIfNeeded()
    }
    
    @objc func documentsModeWasSwitched(notification: Notification) {
        guard let documentsMode = notification.userInfo?["documentsMode"] as? DocumentsMode else { return }
        switch documentsMode {
        case .documents:
            break
        case .euidWallet:
            break
        }
        documentsWasUpdated()
    }
    
    @objc func secondaryDocumentsWasUpdated() {
        self.documents.flatMap({ $0.getValues() }).forEach({ $0.updateIfNeeded() })
    }
    
    var haveAdditionalCard: Bool {
        return true
    }

    func numberOfItems() -> Int {
        return documents.count
    }
    
    func itemAtIndex(index: Int) -> MultiDataType<DocumentModel>? {
        if documents.indices.contains(index) {
            return documents[index]
        }
        return nil
    }

    func selectItem(index: Int) {
        view.flipCurrentItem()
    }
    
    func processAction(action: String) {
        let docCode: DocTypeCode = action
        if !scrollToDoc(type: docCode) {
            scrollingDocType = docCode
        }
    }
    
    func updateBackgroundImage(image: UIImage?) {
        holder.updateBackgroundImage(image: image)
    }
    
    func stackClicked(at index: Int) {
        guard let item = itemAtIndex(index: index) else { return }
        switch item {
        case .single:
            break
        case .multiple:
            if let type = item.getValue().docType {
                context.documentsStackRouterCreate(type).route(in: view)
            }
        }
    }
}

// MARK: - Private Methods
extension DocumentsCollectionPresenter {
    private func setupAddDocumentsService() {
        context.addDocumentsService.setup { [weak self] docTypeCode in
            guard let self = self else { return }
            self.documentsWasUpdated()
            self.scrollToDoc(type: docTypeCode)
        } onExists: { [weak self] docTypeCode in
            guard let self = self else { return }
            self.scrollToDoc(type: docTypeCode)
        }
    }

    private func onNetworkStatus(isReachable: Bool) {
        let text = isReachable ? nil : R.Strings.document_general_reachability_error.localized()
        view.setStatusText(statusText: text)
    }
    
    private func processDocuments() {
        let order: [DocTypeCode] = context.documentsReorderingConfiguration.reorderingService.docTypesOrder()

        var documents: [MultiDataType<DocumentModel>] = context.docProvider.documents(with: order, actionView: view)

        documents.append(.single(addDocumentCard()))

        // TODO: Add eTag checking for equitable protocol

        if !self.documents.map({$0.count}).elementsEqual(documents.map({$0.count})) ||
            !self.documents.map({$0.getValue()}).elementsEqual(documents, by: {
                $0.model == $1.getValue().model
            }) {
            self.documents = documents
            self.view.updateDocuments()
        }
    }

    private func addDocumentCard() -> DocumentModel {
        AddNewDocumentViewModel(addDocumentCallback: { [weak self] in
            guard let self = self else { return }
            self.context.addDocumentsService.showAddDocuments(in: self.view) { [weak self] error in
                guard let self = self else { return }
                let errorType: GeneralError = (error == .noInternet) ? .noInternet : .serverError
                GeneralErrorsHandler.process(error: errorType, in: self.view, forceClose: false)
            }
        }, changeOrderCallback: { [weak self] in
            guard let self = self else { return }
            let module = context.documentsReorderingConfiguration.createReorderingModule()
            self.view.open(module: module)
        })
    }
    
    @discardableResult
    private func scrollToDoc(type: DocTypeCode) -> Bool {
        if !view.isVisible() { return false }
        var index: Int?
        
        for (i, doc) in documents.enumerated() {
            if doc.getValue().docType?.isDocCodeSameAs(otherDocCode: type) ?? false {
                index = i
                break
            }
        }
        
        guard let item = index else { return false }
        view.scroll(to: IndexPath(item: item, section: 0), animated: true)
        return true
    }
    
    private func scrollDocIfNeeded() {
        if let docType = scrollingDocType, scrollToDoc(type: docType) {
            scrollingDocType = nil
        }
    }
}
