import SwiftUI
import UIKit

/// A reusable, scrollable two-page template. The host owns loading, document status,
/// image decoding, fullscreen presentation and dismissal.
public struct PassportBookletView: View {
    public let data: PassportBookletData
    public let photo: UIImage?
    public let signature: UIImage?
    public let pageGap: CGFloat

    private let paper = Color(red: 0.97, green: 0.94, blue: 0.82)
    private let ink = Color(red: 0.12, green: 0.17, blue: 0.24)

    /// Pass the separating hinge width as `pageGap` for a centered dual-screen display.
    public init(data: PassportBookletData, photo: UIImage? = nil,
                signature: UIImage? = nil, pageGap: CGFloat = 1) {
        self.data = data
        self.photo = photo
        self.signature = signature
        self.pageGap = max(0, pageGap)
    }

    public var body: some View {
        GeometryReader { geometry in
            if geometry.size.width - pageGap >= 600 {
                HStack(alignment: .top, spacing: pageGap) {
                    ScrollView { titlePage.frame(maxWidth: .infinity) }.background(paper)
                    ScrollView { identityPage.frame(maxWidth: .infinity) }.background(paper)
                }
                .background(ink.opacity(0.2))
            } else {
                ScrollView {
                    VStack(spacing: 1) {
                        titlePage
                        identityPage
                    }
                }
            }
        }
        .foregroundColor(ink)
        .background(paper)
    }

    private var titlePage: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 0) {
                Color(red: 0, green: 0.36, blue: 0.73)
                Color(red: 1, green: 0.82, blue: 0)
            }
            .frame(width: 96, height: 64)
            .accessibilityLabel(Text("booklet_flag", bundle: .module))

            Text("booklet_title", bundle: .module)
                .font(.system(.title2, design: .serif).weight(.semibold))
                .accessibilityAddTraits(.isHeader)

            Text(data.displayNumber)
                .font(.system(.title3, design: .monospaced))

            field("booklet_issued_at", data.issuance.issuedAt)
            field("booklet_issued_by", data.issuance.issuedBy)
            optionalField("booklet_valid_until", data.issuance.validUntil)
            ForEach(Array((data.additionalFields ?? []).enumerated()), id: \.offset) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.element.label).font(.caption)
                    Text(entry.element.value).font(.body)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
    }

    private var identityPage: some View {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                if let photo = photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel(Text("booklet_photo", bundle: .module))
                } else {
                    Text("booklet_no_photo", bundle: .module)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.05))
                }
            }
            .frame(width: 108, height: 144)

            field("booklet_last_name", data.identity.lastName)
            field("booklet_first_name", data.identity.firstName)
            optionalField("booklet_middle_name", data.identity.middleName)
            field("booklet_birth_date", data.identity.birthDate)
            field("booklet_birth_place", data.identity.birthPlace)
            optionalField("booklet_sex", data.identity.sex)

            if let signature = signature {
                Image(uiImage: signature)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 144, height: 56)
                    .accessibilityLabel(Text("booklet_signature", bundle: .module))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
    }

    private func field(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(label), bundle: .module).font(.caption)
            Text(value).font(.body)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func optionalField(_ label: String, _ value: String?) -> some View {
        if let value = value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            field(label, value)
        }
    }
}

struct PassportBookletView_Previews: PreviewProvider {
    static var previews: some View {
        PassportBookletView(data: PassportBookletData(
            identity: .init(lastName: "ПРИКЛАД", firstName: "Надія", middleName: "Тестівна",
                            birthDate: "24.08.1991", birthPlace: "м. Київ"),
            issuance: .init(series: "АА", number: "000000", issuedAt: "24.08.2007",
                            issuedBy: "Демонстраційні дані")
        ))
        .previewLayout(.fixed(width: 840, height: 600))
    }
}
