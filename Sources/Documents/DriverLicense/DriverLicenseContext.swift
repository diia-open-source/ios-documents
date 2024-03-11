import DiiaCommonTypes
import DiiaDocumentsCommonTypes

public struct DriverLicenseContext {
    let model: DSDocumentData
    let docType: DocumentAttributesProtocol?
    let reservePhotoService: DocumentsReservePhotoServiceProtocol
    let sharingApiClient: SharingDocsApiClientProtocol
    let ratingOpener: RateServiceProtocol
    let faqOpener: FaqOpenerProtocol
    let replacementModule: CreateModuleCallback?
    let docReorderingModule: CreateModuleCallback
    let docStackReorderingModule: CreateModuleCallback
    let storeHelper: DriverLicenseDocumentStorage
    let urlHandler: URLOpenerProtocol
    
    public init(model: DSDocumentData,
                docType: DocumentAttributesProtocol?,
                reservePhotoService: DocumentsReservePhotoServiceProtocol,
                sharingApiClient: SharingDocsApiClientProtocol,
                ratingOpener: RateServiceProtocol,
                faqOpener: FaqOpenerProtocol,
                replacementModule: CreateModuleCallback?,
                docReorderingModule: @escaping CreateModuleCallback,
                docStackReorderingModule: @escaping CreateModuleCallback,
                storeHelper: DriverLicenseDocumentStorage,
                urlHandler: URLOpenerProtocol) {
        self.model = model
        self.docType = docType
        self.reservePhotoService = reservePhotoService
        self.sharingApiClient = sharingApiClient
        self.ratingOpener = ratingOpener
        self.faqOpener = faqOpener
        self.replacementModule = replacementModule
        self.docReorderingModule = docReorderingModule
        self.docStackReorderingModule = docStackReorderingModule
        self.storeHelper = storeHelper
        self.urlHandler = urlHandler
    }
}
