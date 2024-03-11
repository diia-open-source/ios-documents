import ReactiveKit
import UIKit
import DiiaMVPModule
import DiiaNetwork
import DiiaUIComponents
import DiiaCommonTypes
@testable import DiiaDocumentsCommonTypes

struct DocumentViewModelStub: DocumentViewModel {
    var errorViewModel: DiiaUIComponents.DocumentErrorViewModel?
    
    var model: DSDocumentData? = .init(docStatus: 0,
                                      id: "",
                                      docNumber: "",
                                      docData: .init(docName: ""))
    
    var images: [DSDocumentContentData : UIImage] = [:]
    
    var docType: DocumentAttributesProtocol? = nil
    
    var codeViewModel: QRCodeViewModel? = .init(document: DocumentModelMock(),
                                                flippingAction: {})
    
    
}

class DocumentModelMock: DocumentModel {    
    var id: String = ""
    var orderIdentifier: String = ""
    var orderConfigurations: DataOrderConfigurations? = nil
    var shortDescription: String = ""
    var docType: DocumentAttributesProtocol? = DocumentAttributesStub()
    var model: DiiaDocumentsCommonTypes.DSDocumentData?

    var frontView: FrontViewProtocol {
        let view: FrontViewStub = FrontViewStub.fromNib(bundle: Bundle.module)
        return view
    }
    
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
    
    func updateIfNeeded() {}
}

class FrontViewStub: UIView, FrontViewProtocol {
    var contextMenuCallback: Callback? = nil
}

struct DocumentAttributesStub: DocumentAttributesProtocol {
    var docCode: DocTypeCode = "docType"
    var name: String = ""
    var stackName: String = ""
    var faqCategoryId: String = ""
    
    func verificationImage(verificationType: VerificationType) -> UIImage? {
        return nil
    }
    
    func warningModel() -> WarningModel? {
        return nil
    }
    
    var stackIconAppearance: DocumentStackIconAppearance = .black
    var isStaticDoc: Bool = false
    
    func isDocCodeSameAs(otherDocCode: DocTypeCode) -> Bool {
        return docCode == otherDocCode
    }
}
