# Passport booklet template proposal

This adds a reusable SwiftUI presentation component for a Ukrainian passport booklet.
It is a foundation for a document feature, not an enabled passport document type.
It does not add a registry endpoint, persistence, document verification, sharing,
or an entry in the application's document gallery.

The visual arrangement follows an open booklet: a title and issuance page on the
left, and a photograph and identity page on the right. The background and flag are
drawn natively; no sample portrait, personal data, stamp or security artwork is bundled.

## Binding data

The flow is registry/database → authenticated backend → existing document repository
and mapper → `PassportBookletData` plus decoded images → `PassportBookletView`.
The mobile component has no database access. The presentation model below is a proposed
Swift shape, not a declaration of an existing Diia backend contract.

```json
{
  "identity": {
    "lastName": "ПРИКЛАД",
    "firstName": "Надія",
    "middleName": "Тестівна",
    "birthDate": "24.08.1991",
    "birthPlace": "м. Київ",
    "sex": null
  },
  "issuance": {
    "series": "АА",
    "number": "000000",
    "issuedAt": "24.08.2007",
    "issuedBy": "Демонстраційний орган видачі",
    "validUntil": null
  },
  "additionalFields": [{"label": "Додаткові дані", "value": "Демонстраційне значення"}]
}
```

The mapper must supply display-ready date strings and localized extra field labels.
Document numbers remain strings to preserve leading zeros. An absent patronymic,
sex, expiry date, signature or extra field list is supported; do not invent values.
Decode registry image content using the existing image pipeline outside the view.
Pass `nil` when a photo is missing or fails decoding; the view displays a localized
placeholder. Image loading failures must not reuse a previous person's photo.

```swift
import DiiaDocuments
import SwiftUI

// `mappedData`, `decodedPhoto`, and `decodedSignature` come from the document mapper.
let view = PassportBookletView(
    data: mappedData,
    photo: decodedPhoto,
    signature: decodedSignature,
    pageGap: 1
)
let controller = UIHostingController(rootView: view)
controller.modalPresentationStyle = .fullScreen
// Present with the host's existing router and an accessible dismissal action.
```

Replace the view's input when the repository emits new data; no personal data is
retained in component state. The host must distinguish loading, unavailable,
expired or unverified data before presenting the template. Rendering data does not
give it document validity.

## Layout and accessibility

The component fills the area offered by its host and adds no toolbar or tab bar.
At 600 points of usable width it displays equally sized pages side by side, each
with independent vertical scrolling. Otherwise the pages stack in one scroll view.
System fonts support Dynamic Type; names and issuer details wrap without truncation.
Photo and signature have accessibility labels and field labels are grouped with values.

For a centered separating hinge, the host may set `pageGap` to its width. For an
off-center hinge or a horizontal fold, the host must supply a suitable container;
the component does not discover device hinge geometry. Safe-area insets, system
bars, orientation, screen protection and the dismissal action remain host concerns.

## Review and validation

Use the SwiftUI preview for sample data. Also check a narrow phone, a wide tablet,
large accessibility text, long names/issuer/place text, missing photo and signature,
updated images, and optional fields omitted by the server.

`PassportBookletDataTests` exercises Unicode, JSON decoding, omitted optional
fields, required-field failures, extra fields, dates and leading-zero preservation.
Run `DocumentsTests` using the iOS package scheme in Xcode or the consuming app's
iOS test destination. This package and its existing dependencies require an iOS SDK.

Before enabling an actual document, maintainers need to agree on the document code,
API mapping, status/expiry handling, approved design/assets, feature availability,
gallery routing and verification/share behavior. `CONTRIBUTING.md` currently directs
new feature proposals through Issues; this implementation is intended for discussion.
