import UIKit
import ReactiveKit
import DiiaCommonTypes
import DiiaNetwork
import DiiaMVPModule
import DiiaUIComponents
import DiiaDocumentsCommonTypes

class AddNewDocumentViewModel: DocumentModel {
    
    var addDocumentCallback: Callback
    var changeOrderCallback: Callback
    
    init(addDocumentCallback: @escaping Callback,
         changeOrderCallback: @escaping Callback) {
        self.addDocumentCallback = addDocumentCallback
        self.changeOrderCallback = changeOrderCallback
    }
    
    // MARK: - DocumentViewModel
    var id: String { return "" }
    var orderIdentifier: String { return "" }
    var shortDescription: String { return "" }
    var model: DSDocumentData?
    var documentName: String?
    let docType: DocumentAttributesProtocol? = nil
    var images = [DSDocumentContentData: UIImage]()
    var orderConfigurations: DataOrderConfigurations? { return nil }
    var errorViewModel: DocumentErrorViewModel?

    lazy var frontView: FrontViewProtocol = {
        let view: AddNewDocumentView = AddNewDocumentView.fromNib(bundle: Bundle.module)
        view.configure(addDocumentCallback: addDocumentCallback,
                       changeOrderCallback: changeOrderCallback)
        return view
    }()
    
    func backView(for type: VerificationType?, flippingAction: @escaping Callback) -> FlippableEmbeddedView? {
        return nil
    }
    
    func sharingRequest() -> Signal<ShareLinkModel, NetworkError>? {
        return nil
    }
    
    func getCardActions(view: BaseView, flipper: FlipperVerifyProtocol) -> [[Action]] {
        return []
    }
    
    func getInstackCardActions(view: BaseView, flipper: FlipperVerifyProtocol) -> [[Action]] {
        return []
    }
    
    func getAccessibilityMenuAction(view: BaseView, flipper: FlipperVerifyProtocol, inStack: Bool) -> [[DiiaCommonTypes.Action]] {
        let actions =
        [
            [
                Action(title: R.Strings.document_general_add_document.localized(), image: nil, callback: addDocumentCallback),
                Action(title: R.Strings.document_general_change_documents_order.localized(), image: nil, callback: changeOrderCallback)
            ]
        ]
        
        return actions
    }
}
