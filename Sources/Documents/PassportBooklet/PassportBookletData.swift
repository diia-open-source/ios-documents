import Foundation

/// Presentation data for the proposed booklet template, not a registry API contract.
/// Dates are display strings prepared by the document mapper, without timezone conversion.
public struct PassportBookletData: Codable, Equatable {
    public struct Identity: Codable, Equatable {
        public let lastName: String
        public let firstName: String
        public let middleName: String?
        public let birthDate: String
        public let birthPlace: String
        public let sex: String?

        public init(lastName: String, firstName: String, middleName: String? = nil,
                    birthDate: String, birthPlace: String, sex: String? = nil) {
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            self.birthDate = birthDate
            self.birthPlace = birthPlace
            self.sex = sex
        }
    }

    public struct Issuance: Codable, Equatable {
        public let series: String
        public let number: String
        public let issuedAt: String
        public let issuedBy: String
        public let validUntil: String?

        public init(series: String, number: String, issuedAt: String,
                    issuedBy: String, validUntil: String? = nil) {
            self.series = series
            self.number = number
            self.issuedAt = issuedAt
            self.issuedBy = issuedBy
            self.validUntil = validUntil
        }
    }

    public struct Field: Codable, Equatable {
        public let label: String
        public let value: String

        public init(label: String, value: String) {
            self.label = label
            self.value = value
        }
    }

    public let identity: Identity
    public let issuance: Issuance
    public let additionalFields: [Field]?

    public init(identity: Identity, issuance: Issuance, additionalFields: [Field]? = nil) {
        self.identity = identity
        self.issuance = issuance
        self.additionalFields = additionalFields
    }

    public var displayNumber: String {
        [issuance.series, issuance.number]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
