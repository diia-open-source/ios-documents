import Foundation
import DiiaDocumentsCommonTypes

public protocol DriverLicenseDocumentStorage {
    func saveDriverLicense(document: DSFullDocumentModel)
    func getDriverLicenseDocument() -> DSFullDocumentModel?
}
