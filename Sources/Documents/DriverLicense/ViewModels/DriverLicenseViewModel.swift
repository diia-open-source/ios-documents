import UIKit
import ReactiveKit
import DiiaMVPModule
import DiiaNetwork
import DiiaUIComponents
import DiiaCommonTypes
import DiiaDocumentsCommonTypes

// MARK: - DriverLicenseViewModel
public final class DriverLicenseViewModel: DocumentModel, DocumentViewModel {
    private let context: DriverLicenseContext
    
    var docStatus: DriverLicenseStatus

    public var model: DSDocumentData?
    public let docType: DocumentAttributesProtocol?
    public var id: String { model?.id ?? "" }
    public var orderIdentifier: String { model?.docNumber ?? "" }
    public var images = [DSDocumentContentData: UIImage]()
    public var errorViewModel: DocumentErrorViewModel?
    public var documentName: String? {
        return model?.docData.name
    }
    
    public lazy var codeViewModel: QRCodeViewModel? = {
        return QRCodeViewModel(document: self, flippingAction: {}, localization: model?.shareLocalization ?? .ua)
    }()
    
    public init(context: DriverLicenseContext) {
        self.context = context
        
        self.model = context.model
        self.docType = context.docType
        self.docStatus = DriverLicenseStatus(fromRawValue: context.model.docStatus)
        self.errorViewModel = context.model.currentLocalization() == .en ? docStatus.generateErrorViewModelEn(urlHandlerType: context.urlHandler) : docStatus.generateErrorViewModel(urlHandlerType: context.urlHandler)

        context.model.content?.forEach({ images[$0.code] = UIImage.createWithBase64String($0.image) })
        if images[.photo] == nil || context.model.content?.first(where: {$0.code == .photo})?.image.isEmpty == true {
            let photo = context.reservePhotoService.findReservePassportPhoto()
            images[.photo] = UIImage.createWithBase64String(photo)
        }
        
        if context.model.docStatus == DriverLicenseStatus.noPhoto.rawValue && images[.photo] != nil {
            errorViewModel = nil
            return
        }
    }
    
    public var shortDescription: String {
        return model?.docNumber ?? ""
    }
    
    lazy public var frontView: FrontViewProtocol = {
        let view = DSDocumentWithPhotoView()
        view.configure(for: self)
        return view
    }()
    
    public func backView(for type: VerificationType?, flippingAction: @escaping Callback) -> FlippableEmbeddedView? {
        if self.errorViewModel == nil {
            let view = QRCodeBarcodeView()
            view.configure(viewModel: QRCodeViewModel(document: self,
                                                      flippingAction: flippingAction,
                                                      localization: model?.currentLocalization() ?? .ua,
                                                      type: type))
            return view
        }
        return nil
    }
    
    public func sharingRequest() -> Signal<ShareLinkModel, NetworkError>? {
        return context.sharingApiClient.shareDriverLicense(documentId: self.id, localization: model?.shareLocalization?.rawValue)
    }
    
    // MARK: - Actions
    public func getCardActions(view: BaseView, flipper: FlipperVerifyProtocol) -> [[Action]] {
        var actions = commonActions(view: view)
        actions.append([
            Action(title: R.Strings.document_general_rate.localized(),
                   image: R.Image.ds_rating.image,
                   callback: { [weak self, weak view] in
                       guard let self = self, let view = view else { return }
                       self.context.ratingOpener.rateDocument(documentType: PackageConstants.packageDocType, successCallback: nil, in: view)
                   }),
            Action(
                title: R.Strings.document_general_change_documents_order.localized(),
                image: R.Image.ds_reorder.image,
                callback: { [weak self, weak view] in
                    guard let self = self, let view = view else { return }
                    view.open(module: self.context.docReorderingModule())
                }),
            Action(
                title: R.Strings.menu_faq.localized(),
                image: R.Image.ds_faq.image,
                callback: { [weak self, weak view] in
                    guard let self = self, let view = view else { return }
                    self.context.faqOpener.openFaq(category: self.docType?.faqCategoryId ?? "", in: view)
                })
        ])
        return actions
    }
    
    public func getInstackCardActions(view: BaseView, flipper: FlipperVerifyProtocol) -> [[Action]] {
        var actions = commonActions(view: view)
        actions.append([
            Action(title: R.Strings.document_general_rate.localized(),
                   image: R.Image.ds_rating.image,
                   callback: { [weak self, weak view] in
                       guard let self = self, let view = view else { return }
                       self.context.ratingOpener.rateDocument(documentType: PackageConstants.packageDocType, successCallback: nil, in: view)
                   }),
            Action(
                title: R.Strings.document_general_change_stack_documents_order.localized(),
                image: R.Image.ds_reorder.image,
                callback: { [weak self, weak view] in
                    guard let self = self, let view = view else { return }
                    view.open(module: self.context.docStackReorderingModule())
                }),
            Action(
                title: R.Strings.menu_faq.localized(),
                image: R.Image.ds_faq.image,
                callback: { [weak self, weak view] in
                    guard let self = self, let view = view else { return }
                    self.context.faqOpener.openFaq(category: self.docType?.faqCategoryId ?? "", in: view)
                })
        ])
        return actions
    }
    
    private func commonActions(view: BaseView) -> [[Action]] {
        return [
            [
                Action(title: R.Strings.action_title_full_info.localized(),
                       image: R.Image.ds_docInfo.image,
                       callback: { [weak view, weak self] in
                           guard let self else { return }
                           let passportDetails = DSDocumentDetailsModule(with: self)
                           view?.showChild(module: passportDetails)
                       }),
                Action(title: model?.shareLocalization == .en ? R.Strings.general_translate_ukrainian.localized() : R.Strings.general_translate_english.localized(),
                       image: model?.shareLocalization == .ua ? R.Image.translate_english.image : R.Image.translate_ukrainian.image,
                       callback: { [weak self] in
                           self?.translate()
                       })
            ],
            [
                Action(title: R.Strings.driver_license_replacement.localized(),
                       image: R.Image.ds_refresh.image,
                       callback: { [weak view] in
                           guard let module = self.context.replacementModule?() else { return }
                           view?.open(module: module)
                       })
            ]
        ]
    }
    
    private func translate() {
        guard let driverLicense: DSFullDocumentModel = context.storeHelper.getDriverLicenseDocument() else { return }
        
        let newLocalization: LocalizationType
        if model?.shareLocalization != .en {
            newLocalization = .en
        } else {
            newLocalization = .ua
        }
        context.storeHelper.saveDriverLicense(document: DSFullDocumentModel(status: driverLicense.status,
                                                                            expirationDate: driverLicense.expirationDate,
                                                                            currentDate: driverLicense.currentDate,
                                                                            data: driverLicense.data.map {
                                                                                if $0.id == self.id {
                                                                                    return .init(passport: $0, shareLocalization: newLocalization)
                                                                                } else {
                                                                                    return $0
                                                                                }
                                                                            }))
        NotificationCenter.default.post(name: DocumentsConstants.Notifications.documentsWasReordered, object: nil)
    }
}
