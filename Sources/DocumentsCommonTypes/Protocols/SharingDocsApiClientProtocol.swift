
import Foundation
import ReactiveKit
import DiiaNetwork

// reason for location: is used by DriverLicenseDocument package and Diia itself
public protocol SharingDocsApiClientProtocol {
    // MARK: - Share
    func shareDocument(docType: String, documentId: String, localization: String?) -> Signal<ShareVerificationCodesModel, NetworkError>
    func shareDriverLicense(documentId: String, localization: String?) -> Signal<ShareLinkModel, NetworkError>
}
