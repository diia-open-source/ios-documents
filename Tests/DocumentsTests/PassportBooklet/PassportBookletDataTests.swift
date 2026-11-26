import XCTest
@testable import DiiaDocuments

final class PassportBookletDataTests: XCTestCase {
    private let minimalJSON = #"""
    {
      "identity": {
        "lastName": "ПРИКЛАД", "firstName": "Надія",
        "birthDate": "24.08.1991", "birthPlace": "м. Івано-Франківськ"
      },
      "issuance": {
        "series": "АА", "number": "000001", "issuedAt": "24.08.2007",
        "issuedBy": "Демонстраційний орган видачі"
      }
    }
    """#

    func testDecodesCyrillicAndOmittedOptionalFields() throws {
        let data = try JSONDecoder().decode(PassportBookletData.self, from: Data(minimalJSON.utf8))
        XCTAssertEqual(data.identity.firstName, "Надія")
        XCTAssertEqual(data.identity.birthPlace, "м. Івано-Франківськ")
        XCTAssertEqual(data.displayNumber, "АА 000001")
        XCTAssertNil(data.identity.middleName)
        XCTAssertNil(data.issuance.validUntil)
        XCTAssertNil(data.additionalFields)
    }

    func testRoundTripPreservesAdditionalFieldsAndDateStrings() throws {
        let source = try JSONDecoder().decode(PassportBookletData.self, from: Data(minimalJSON.utf8))
        let data = PassportBookletData(
            identity: source.identity,
            issuance: source.issuance,
            additionalFields: [.init(label: "Місце проживання", value: "м. Київ, тестова адреса")]
        )
        let result = try JSONDecoder().decode(PassportBookletData.self, from: JSONEncoder().encode(data))
        XCTAssertEqual(result, data)
        XCTAssertEqual(result.identity.birthDate, "24.08.1991")
        XCTAssertEqual(result.additionalFields?.first?.value, "м. Київ, тестова адреса")
    }

    func testMissingRequiredIdentityIsRejected() {
        let json = minimalJSON.replacingOccurrences(of: "\"firstName\": \"Надія\",", with: "")
        XCTAssertThrowsError(try JSONDecoder().decode(PassportBookletData.self, from: Data(json.utf8)))
    }

    func testNumberPreservesLeadingZerosWithoutExtraWhitespace() {
        let data = PassportBookletData(
            identity: .init(lastName: "ПРИКЛАД", firstName: "Надія", birthDate: "", birthPlace: ""),
            issuance: .init(series: " \n", number: " 000001 ", issuedAt: "", issuedBy: "")
        )
        XCTAssertEqual(data.displayNumber, "000001")
    }
}
