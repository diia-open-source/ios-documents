import Foundation
import ReactiveKit
import DiiaCommonTypes
import DiiaNetwork
import DiiaUIComponents
import DiiaMVPModule
import DiiaDocumentsCommonTypes

public protocol AddDocumentsActionProviderProtocol: AnyObject {
    func action(for doc: DocsToAddModel, in view: BaseView, onDocumentAdded: Callback?, onDocumentExist: Callback?) -> Action?
}

typealias AddDocumentCallback = (DocTypeCode) -> Void

protocol AddDocumentsServiceProtocol {
    func setup(onAdded: @escaping AddDocumentCallback, onExists: @escaping AddDocumentCallback)
    func showAddDocuments(in view: BaseView, errorCallback: ((NetworkError) -> Void)?)
}

class AddDocumentsService: AddDocumentsServiceProtocol {
    private let apiClient: AddDocumentAPIClientProtocol
    private let addDocumentActionProvider: AddDocumentsActionProviderProtocol

    private var onAdded: ((DocTypeCode) -> Void)?
    private var onExists: ((DocTypeCode) -> Void)?
    
    private let bag = DisposeBag()

    init(addDocumentsActionProvider: AddDocumentsActionProviderProtocol, apiClient: AddDocumentAPIClientProtocol) {
        self.addDocumentActionProvider = addDocumentsActionProvider
        self.apiClient = apiClient
    }
    
    func setup(onAdded: @escaping AddDocumentCallback, onExists: @escaping AddDocumentCallback) {
        self.onAdded = onAdded
        self.onExists = onExists
    }

    func showAddDocuments(in view: BaseView, errorCallback: ((NetworkError) -> Void)?) {
        view.showProgress()

        fetchDocuments(successCallback: { [weak self, weak view] docsToAdd in
            guard let self = self, let view = view else { return }

            view.hideProgress()

            let actions = docsToAdd.compactMap { docsToAdd in
                self.addDocumentActionProvider.action(
                    for: docsToAdd,
                    in: view,
                    onDocumentAdded: { [weak self] in
                        self?.onAdded?(docsToAdd.code)
                    },
                    onDocumentExist: { [weak self] in
                        self?.onExists?(docsToAdd.code)
                    })
            }

            guard actions.count > 0 else {
                errorCallback?(.noData)
                return
            }
            let module = ActionSheetModule(actions: actions.map({[$0]}))
            view.showChild(module: module)
        }, errorCallback: { [weak view] error in
            view?.hideProgress()
            errorCallback?(error)
        })
    }
    
    // MARK: - Private Methods
    private func fetchDocuments(
        successCallback: (([DocsToAddModel]) -> Void)? = nil,
        errorCallback: ((NetworkError) -> Void)? = nil
    ) {
        apiClient.getDocsToAdd().observe { event in
            switch event {
            case .completed:
                break
            case .failed(let error):
                errorCallback?(error)
            case .next(let docsToAdd):
                if docsToAdd.documents.count > 0 {
                    successCallback?(docsToAdd.documents)
                    return
                }
                errorCallback?(.noData)
            }
        }.dispose(in: bag)
    }
}
