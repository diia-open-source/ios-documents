import UIKit
import ReactiveKit
import DiiaNetwork
import DiiaMVPModule
import DiiaCommonTypes
import DiiaUIComponents
import DiiaDocumentsCommonTypes
@testable import DiiaDocumentsCore

class DocumentModelMock: DocumentModel {
    private(set) var isUpdateIfNeeded: Bool = false
    private let actions: [[Action]]
    
    init(actions: [[Action]] = []) {
        self.actions = actions
    }
    
    // MARK: - DocumentModel
    var id: String = ""
    var orderIdentifier: String = ""
    var frontView: FrontViewProtocol {
        let view: FrontViewStub = FrontViewStub.fromNib(bundle: Bundle.module)
        return view
    }
    var docType: DocumentAttributesProtocol? = DocumentAttributesStub()
    var shortDescription: String = ""
    var orderConfigurations: DataOrderConfigurations? = nil
    var model: DiiaDocumentsCommonTypes.DSDocumentData?

    func backView(for type: VerificationType?, flippingAction: @escaping Callback) -> FlippableEmbeddedView? {
        return nil
    }
    
    func sharingRequest() -> Signal<ShareLinkModel, NetworkError>? {
        return nil
    }
    
    func getCardActions(view: BaseView, flipper: FlipperVerifyProtocol) -> [[Action]] {
        return actions
    }
    
    func getInstackCardActions(view: BaseView, flipper: FlipperVerifyProtocol) -> [[Action]] {
        return actions
    }
    
    func updateIfNeeded() {
        isUpdateIfNeeded.toggle()
    }
    
}
