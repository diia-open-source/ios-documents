import UIKit
import ReactiveKit
import DiiaMVPModule
import DiiaNetwork
import DiiaCommonTypes
import DiiaUIComponents

public protocol DocumentModel: AnyObject {
    var id: String { get }
    var model: DSDocumentData? { get }
    var orderIdentifier: String { get }
    var docType: DocumentAttributesProtocol? { get }
    var shortDescription: String { get }
    var orderConfigurations: DataOrderConfigurations? { get }
    
    var frontView: FrontViewProtocol { get }
    func backView(for type: VerificationType?, flippingAction: @escaping Callback) -> FlippableEmbeddedView?
    
    func sharingRequest() -> Signal<ShareLinkModel, NetworkError>?
    func getCardActions(view: BaseView, flipper: FlipperVerifyProtocol) -> [[Action]]
    func getInstackCardActions(view: BaseView, flipper: FlipperVerifyProtocol) -> [[Action]]
    func updateIfNeeded()
}

public extension DocumentModel {
    var documentName: String? { return model?.docData.docName }
    var orderConfigurations: DataOrderConfigurations? { return nil }

    func updateIfNeeded() {}
}

public protocol DocumentViewModel {
    var model: DSDocumentData? { get }
    var images: [DSDocumentContentData: UIImage] { get }
    var docType: DocumentAttributesProtocol? { get }
    var codeViewModel: QRCodeViewModel? { get }
    var errorViewModel: DocumentErrorViewModel? { get set }
}

public extension DocumentViewModel {
    var errorViewModel: DocumentErrorViewModel? { return nil }
    var nameRaw: String { return model?.docData.fullName ?? "" }
}

public protocol FrontViewProtocol: FlippableEmbeddedView, VerifyDocumentViewProtocol {
    var contextMenuCallback: Callback? { get set }
}

// MARK: - Protocols
public protocol FlipperVerifyProtocol: AnyObject {
    func flip(for: VerificationType?)
}

public protocol FlippableEmbeddedView: UIView {
    func willPresent()
    func willHide()
    func didHide()
    func didChangeFocus(isFocused: Bool)
}

extension FlippableEmbeddedView {
    public func willPresent() {}
    public func willHide() {}
    public func didHide() {}
    public func didChangeFocus(isFocused: Bool) {}
}

// it is required for verification feature, that is not moved into DocumentCore, but VerifyDocumentViewProtocol is used in DocumentModel
public protocol VerifyDocumentViewProtocol: UIView {
    func verifyDocumentViewDidChangeLayout()
}

public extension VerifyDocumentViewProtocol {
    func verifyDocumentViewDidChangeLayout() {}
}
