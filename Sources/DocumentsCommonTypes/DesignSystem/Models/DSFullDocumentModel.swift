
import Foundation
import DiiaUIComponents
import DiiaCommonTypes

public struct DSFullDocumentModel: StatusedExpirableProtocol {
    
    public var status: DocumentStatusCode
    public var expirationDate: Date
    public let currentDate: Date
    public let data: [DSDocumentData]
    
    // MARK: - Init
    public init(status: DocumentStatusCode,
                expirationDate: Date,
                currentDate: Date,
                data: [DSDocumentData]) {
        self.status = status
        self.expirationDate = expirationDate
        self.currentDate = currentDate
        self.data = data
    }

    public func withLocalization(shareLocalization: LocalizationType) -> DSFullDocumentModel {
        return .init(status: status,
                     expirationDate: expirationDate,
                     currentDate: currentDate,
                     data: data.map { DSDocumentData(passport: $0, shareLocalization: shareLocalization) })
    }

    /// Remove certificates that expires before refference date.
    /// - Parameters:
    ///   - expirationDate: refference date
    /// - Returns: updated  document model.
    ///

    public func getFilteredDoc(by expirationDate: Date) -> DSFullDocumentModel {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return DSFullDocumentModel(status: self.status,
                                   expirationDate: self.expirationDate,
                                   currentDate: self.currentDate,
                                   data: data.filter { data in
            if let validUntil = data.docData.validUntil,
               let docExpiration = dateFormatter.date(from: validUntil),
               docExpiration < expirationDate {
                return false
            }
            return true
        })
    }

    public func updateDocument(with updatedCertificate: DSFullDocumentModel) -> DSFullDocumentModel {
        var documentsData: [DSDocumentData] = []
        if updatedCertificate.status == .ok || updatedCertificate.status == .notFound {
            documentsData = Set(updatedCertificate.data + self.data).uniqued()
        } else {
            documentsData = self.data
        }

        return DSFullDocumentModel(status: updatedCertificate.status,
                                   expirationDate: updatedCertificate.expirationDate,
                                   currentDate: updatedCertificate.currentDate,
                                   data: documentsData)
    }

    /// When we receive requested certificate and have existing ones we need to update fetched model with stored certificates.
    /// - Parameter storedDocs: certificate data stored on device that we need to append to the fetched model.
    /// - Returns: updated child certificate model.
    public func getDocument(appending storedDocs: [DSDocumentData]) -> DSFullDocumentModel {
        return DSFullDocumentModel(status: status,
                                   expirationDate: expirationDate,
                                   currentDate: currentDate,
                                   data: data + storedDocs)
    }

}

public struct DSDocumentData: Codable, Hashable {

    public let docStatus: Int
    public let id: String
    public let qr: String?
    public let docNumber: String
    public let content: [DSDocumentContent]?
    public let docData: DSDocData
    public let dataForDisplayingInOrderConfigurations: DataOrderConfigurations?
    public let dataForDisplayingAsListItem: DSListGroupItem?
    public let frontCard: DSDocumentFrontCard?
    public let fullInfo: [AnyCodable]?
    public let shareLocalization: LocalizationType?
    public let frontCardBackground: String?
    public let cover: Cover?

    public init(docStatus: Int,
                id: String,
                qr: String? = nil,
                docNumber: String,
                content: [DSDocumentContent]? = nil,
                docData: DSDocData,
                dataForDisplayingInOrderConfigurations: DataOrderConfigurations? = nil,
                dataForDisplayingAsListItem: DSListGroupItem? = nil,
                frontCard: DSDocumentFrontCard? = nil,
                fullInfo: [AnyCodable]? = nil,
                shareLocalization: LocalizationType? = nil,
                frontCardBackground: String? = nil,
                cover: Cover? = nil) {
        self.docStatus = docStatus
        self.id = id
        self.qr = qr
        self.docNumber = docNumber
        self.content = content
        self.docData = docData
        self.dataForDisplayingInOrderConfigurations = dataForDisplayingInOrderConfigurations
        self.dataForDisplayingAsListItem = dataForDisplayingAsListItem
        self.frontCard = frontCard
        self.fullInfo = fullInfo
        self.shareLocalization = shareLocalization
        self.frontCardBackground = frontCardBackground
        self.cover = cover
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(docNumber)
        hasher.combine(docStatus)
    }

    public static func == (lhs: DSDocumentData, rhs: DSDocumentData) -> Bool {
        return lhs.docNumber == rhs.docNumber &&
        lhs.id == rhs.id &&
        lhs.docStatus == rhs.docStatus &&
        lhs.docData == rhs.docData &&
        lhs.dataForDisplayingInOrderConfigurations == rhs.dataForDisplayingInOrderConfigurations &&
        lhs.shareLocalization == rhs.shareLocalization &&
        lhs.frontCard == rhs.frontCard
    }

    public func currentLocalization() -> LocalizationType? {
        if shareLocalization == nil {
            if frontCard?.UA == nil || frontCard?.UA?.isEmpty == true {
                if frontCard?.EN == nil || frontCard?.EN?.isEmpty == true {
                    return nil
                } else {
                    return .en
                }
            } else {
                return .ua
            }
        } else {
            return shareLocalization
        }
    }
}

public struct DataOrderConfigurations: Codable, Equatable {
    public let iconRight: IconCode
    public let label: String
    public let description: String

    public init(iconRight: IconCode,
                label: String,
                description: String) {
        self.iconRight = iconRight
        self.label = label
        self.description = description
    }
}

public enum BOOL: String, Codable {
    case yes, no
}

public struct IconCode: Codable, Equatable {
    public let code: String

    public init(code: String) {
        self.code = code
    }
}

public extension DSDocumentData {
    init(passport: DSDocumentData, shareLocalization: LocalizationType) {
        self.docStatus = passport.docStatus
        self.id = passport.id
        self.qr = passport.qr
        self.docNumber = passport.docNumber
        self.content = passport.content
        self.docData = passport.docData
        self.frontCard = passport.frontCard
        self.dataForDisplayingInOrderConfigurations = passport.dataForDisplayingInOrderConfigurations
        self.dataForDisplayingAsListItem = passport.dataForDisplayingAsListItem
        self.frontCardBackground = passport.frontCardBackground
        self.fullInfo = passport.fullInfo
        self.shareLocalization = shareLocalization
        self.cover = passport.cover
    }
}

public struct DSDocData: Codable, Equatable {
    public let docName: String
    public let docType: String?
    public let birthday: String?
    public let rnokpp: String?
    public let birthPlace: String?
    public let invalidGroup: String?
    public let validUntil: String?
    public let booster: BOOL?
    public let disease: String?
    public let vaccine: String?
    public let vaccineProduct: String?
    public let vaccineHolder: String?
    public let numberVaccine: String?
    public let vaccinationDate: String?
    public let member: String?
    public let certificateIssuer: String?
    public let firstPositiveTime: String?
    public let testType: String?
    public let testName: String?
    public let testManufacturer: String?
    public let sampleCollectionTime: String?
    public let resultTestTime: String?
    public let result: String?
    public let testCenter: String?
    public let ownerType: OwnerType?
    public let mark: String?
    public let model: String?
    public let vin: String?
    public let owner: String?
    public let properUser: String?
    public let updateDate: String?
    public let fullName: String?
    public let partnerFullName: String?
    public let licensePlate: String?
    public let vehicleLicenseId: String?
    public let serialNumber: String?
    public let serial: String?
    public let number: String?
    public let status: String?
    public let docStatus: String?
    public let name: String?
    public let educationInstitutionName: String?
    public let dataIssued: String?
    public let awardType: AwardType?
    public let fullNameEng: String?
    public let birthCertificateId: String?
    public let properUserUntil: String?
    public let properUserExpirationDate: String?
    public let source: String?
    public let zodiacSign: String?
    public let tickerType: String?
    public let tickerValue: String?
    public let dateIssued: String?
    public let subType: String?
    public let type: String?
    
    public init(docName: String,
                docType: String? = nil,
                birthday: String? = nil,
                rnokpp: String? = nil,
                birthPlace: String? = nil,
                invalidGroup: String? = nil,
                validUntil: String? = nil,
                booster: BOOL? = nil,
                disease: String? = nil,
                vaccine: String? = nil,
                vaccineProduct: String? = nil,
                vaccineHolder: String? = nil,
                numberVaccine: String? = nil,
                vaccinationDate: String? = nil,
                member: String? = nil,
                certificateIssuer: String? = nil,
                firstPositiveTime: String? = nil,
                testType: String? = nil,
                testName: String? = nil,
                testManufacturer: String? = nil,
                sampleCollectionTime: String? = nil,
                resultTestTime: String? = nil,
                result: String? = nil,
                testCenter: String? = nil,
                mark: String? = nil,
                model: String? = nil,
                vin: String? = nil,
                owner: String? = nil,
                properUser: String? = nil,
                updateDate: String? = nil,
                fullName: String? = nil,
                fullNameEng: String? = nil,
                partnerFullName: String? = nil,
                licensePlate: String? = nil,
                vehicleLicenseId: String? = nil,
                serialNumber: String? = nil,
                serial: String? = nil,
                number: String? = nil,
                status: String? = nil,
                docStatus: String? = nil,
                name: String? = nil,
                educationInstitutionName: String? = nil,
                dataIssued: String? = nil,
                awardType: AwardType? = nil,
                birthCertificateId: String? = nil,
                ownerType: OwnerType? = nil,
                properUserUntil: String? = nil,
                source: String? = nil,
                properUserExpirationDate: String? = nil,
                zodiacSign: String? = nil,
                tickerType: String? = nil,
                dateIssued: String? = nil,
                tickerValue: String? = nil,
                subType: String? = nil,
                type: String? = nil
    ) {
        self.docName = docName
        self.docType = docType
        self.birthday = birthday
        self.rnokpp = rnokpp
        self.birthPlace = birthPlace
        self.invalidGroup = invalidGroup
        self.validUntil = validUntil
        self.booster = booster
        self.disease = disease
        self.vaccine = vaccine
        self.vaccineProduct = vaccineProduct
        self.vaccineHolder = vaccineHolder
        self.numberVaccine = numberVaccine
        self.vaccinationDate = vaccinationDate
        self.member = member
        self.certificateIssuer = certificateIssuer
        self.firstPositiveTime = firstPositiveTime
        self.testType = testType
        self.testName = testName
        self.testManufacturer = testManufacturer
        self.sampleCollectionTime = sampleCollectionTime
        self.resultTestTime = resultTestTime
        self.result = result
        self.testCenter = testCenter
        self.mark = mark
        self.model = model
        self.vin = vin
        self.owner = owner
        self.properUser = properUser
        self.updateDate = updateDate
        self.fullName = fullName
        self.fullNameEng = fullNameEng
        self.partnerFullName = partnerFullName
        self.licensePlate = licensePlate
        self.vehicleLicenseId = vehicleLicenseId
        self.serialNumber = serialNumber
        self.serial = serial
        self.number = number
        self.status = status
        self.docStatus = docStatus
        self.name = name
        self.educationInstitutionName = educationInstitutionName
        self.dataIssued = dataIssued
        self.awardType = awardType
        self.birthCertificateId = birthCertificateId
        self.ownerType = ownerType
        self.properUserUntil = properUserUntil
        self.properUserExpirationDate = properUserExpirationDate
        self.source = source
        self.zodiacSign = zodiacSign
        self.tickerType = tickerType
        self.tickerValue = tickerValue
        self.dateIssued = dateIssued
        self.subType = subType
        self.type = type
    }
}

public struct DSDocumentContent: Codable {
    public let image: String
    public let code: DSDocumentContentData

    public init(image: String,
                code: DSDocumentContentData) {
        self.image = image
        self.code = code
    }
}

public struct DSDocumentFrontCard: Codable, Equatable {
    public let UA: [DSDocumentModel]?
    public let EN: [DSDocumentModel]?

    public init(UA: [DSDocumentModel]?,
                EN: [DSDocumentModel]?) {
        self.UA = UA
        self.EN = EN
    }
}

public struct DSDocumentModel: Codable, Equatable {
    public let docHeadingOrg: DSDocumentHeading?
    public let tableBlockTwoColumnsPlaneOrg: DSTableBlockTwoColumnPlaneOrg?
    public let tableBlockPlaneOrg: DSTableBlockItemModel?
    public let subtitleLabelMlc: DSTitleLabelMlc?
    public let tickerAtm: DSTickerAtom?
    public let docButtonHeadingOrg: DSDocumentHeading?
    public let chipStatusAtm: DSCardStatusChipModel?
    public let smallEmojiPanelMlc: DSSmallEmojiPanelMlcl?

    public init(docHeadingOrg: DSDocumentHeading? = nil,
                tableBlockTwoColumnsPlaneOrg: DSTableBlockTwoColumnPlaneOrg? = nil,
                tableBlockPlaneOrg: DSTableBlockItemModel? = nil,
                subtitleLabelMlc: DSTitleLabelMlc? = nil,
                tickerAtm: DSTickerAtom? = nil,
                docButtonHeadingOrg: DSDocumentHeading? = nil,
                smallEmojiPanelMlc: DSSmallEmojiPanelMlcl? = nil,
                chipStatusAtm: DSCardStatusChipModel? = nil) {
        self.docHeadingOrg = docHeadingOrg
        self.tableBlockTwoColumnsPlaneOrg = tableBlockTwoColumnsPlaneOrg
        self.tableBlockPlaneOrg = tableBlockPlaneOrg
        self.subtitleLabelMlc = subtitleLabelMlc
        self.tickerAtm = tickerAtm
        self.docButtonHeadingOrg = docButtonHeadingOrg
        self.smallEmojiPanelMlc = smallEmojiPanelMlc
        self.chipStatusAtm = nil
    }
    
    public func allPropertiesNil() -> Bool {
        return docHeadingOrg == nil &&
        tableBlockTwoColumnsPlaneOrg == nil &&
        tableBlockPlaneOrg == nil &&
        subtitleLabelMlc == nil &&
        tickerAtm == nil &&
        docButtonHeadingOrg == nil &&
        chipStatusAtm == nil &&
        smallEmojiPanelMlc == nil
    }
}

public struct DSDocumentOther: Codable {
    public let label: String?
    public let value: String?
    public let valueImage: String?

    public init(label: String?,
                value: String?,
                valueImage: String?) {
        self.label = label
        self.value = value
        self.valueImage = valueImage
    }
}

public struct Cover: Codable {
    public let title: String
    public let text: String
    public let actionButton: CoverActionButton?

    public init(title: String,
                text: String,
                actionButton: CoverActionButton?) {
        self.title = title
        self.text = text
        self.actionButton = actionButton
    }
}

public enum CoverAction: String, Codable {
    case deleteDocument
}

public struct CoverActionButton: Codable {
    public let name: String
    public let action: CoverAction

    public init(name: String, action: CoverAction) {
        self.name = name
        self.action = action
    }
}
