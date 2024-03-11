# DiiaDocuments

Documents core functionality and Driver License document

## Description

- Documents core is presented by `DocumentsCollectionModule`, it presents collection of documents that are passed into it
- Driver License document is presented by `DriverLicenseViewModel`

## Useful Links

|Topic|Link|Description|
|--|--|--|
|Ministry of Digital Transformation of Ukraine|https://thedigital.gov.ua/|The Official homepage of the Ministry of Digital Transformation of Ukraine| 
|Diia App|https://diia.gov.ua/|The Official website for the Diia application

## Getting Started

### Installing

To install DiiaDocuments using [Swift Package Manager](https://github.com/apple/swift-package-manager) you can follow the [tutorial published by Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for this repo with the current version:

1. In Xcode, select “File” → “Add Packages...”
2. Enter `https://github.com/diia-open-source/ios-documents.git`

or you can add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/diia-open-source/ios-documents.git", from: "1.0.0")
```

## Usage

### `DocumentsCollectionModule`

Entry point for `DiiaDocumentsCore` that depends on `DocumentsCollectionModuleСontext` and `DocumentCollectionHolderProtocol`.

```swift
import DiiaNetwork
import DiiaDocumentsCommonTypes
import DiiaDocumentsCore

struct DocumentsCollectionModuleFactory {
    
    // Dependencies in the context should be defined or confirmed at the project level as shown in the example.
    static func create(holder: DocumentCollectionHolderProtocol) -> DocumentsCollectionModule {
        let network: DocumentsCoreNetworkContext = .create()
        // Get an instance responsible for fetching docs 
        let documentsLoader: DocumentsLoaderProtocol = ServicesProvider.documentsLoader()
        // Get an instance responsible for providing docs
        let docProcessor: DocumentsProvider = DocumentsProcessor()
        let documentsStackRouterCreate: (DocumentAttributesProtocol) -> RouterProtocol = { DocumentsStackRouter(docType: $0, docProcessor: DocumentsProcessor()) }
        let actionFabricAllowedCodes: [DocTypeCode] = [DocType.driverLicense.docCode]
        // Make an instance that injects CreateModuleCallback and DocumentReorderingServiceProtocol
        let reorderingConfig = DocumentsReorderingConfiguration(createReorderingModule: { DocumentsReorderingModule() },
                                                                documentsReorderingService: DocumentReorderingService.shared)
        let pushNotificationsSharingSubject: PassthroughSubject<Void, Never> = PushNotificationsSharingSubjectImpl()
        let addDocumentsActionProvider: AddDocumentsActionProviderProtocol = AddDocumentsActionProviderImpl()
        let imageNameProvider: DSImageNameProvider = DSImageNameProviderImpl()
        let screenBrightnessService: ScreenBrightnessServiceProtocol = ScreenBrightnessServiceImpl()
        
        return  .init(context: DocumentsCollectionModuleСontext(network: network,
                                                                documentsLoader: documentsLoader,
                                                                docProvider: docProcessor,
                                                                documentsStackRouterCreate: documentsStackRouterCreate,
                                                                actionFabricAllowedCodes: actionFabricAllowedCodes,
                                                                documentsReorderingConfiguration: reorderingConfig,
                                                                pushNotificationsSharingSubject: pushNotificationsSharingSubject,
                                                                addDocumentsActionProvider: addDocumentsActionProvider,
                                                                imageNameProvider: imageNameProvider,
                                                                screenBrightnessService: ScreenBrightnessHelper.shared),
                      holder: holder
        )
    }
}

extension DocumentsCoreNetworkContext {
    static func create() -> DocumentsCoreNetworkContext {
        // Retrieve preconfigured default session from DiiaNetwork.NetworkConfiguration
        let session = NetworkConfiguration.default.session
        let host = "localhost:443"
        // Define base headers for documents API endpoint
        let headers = ["App-Version": "1.0.0",
                       "User-Agent": "user-agent-value"]
                       
        return .init(session: session,
                     host: host,
                     headers: headers)
    }
}
```

### `DriverLicenseViewModel`

Entry point for `DiiaDocuments.DriverLicense` that depends on `DriverLicenseContext`.

```swift
import DiiaDocuments
import DiiaDocumentsCommonTypes

struct DriverLicenseViewModelFactory {
    
    // Dependencies in the context should be defined or confirmed at the project level as shown in the example.
    func createViewModel(model: DSDocumentData) -> DriverLicenseViewModel {
        let docType: DocumentAttributesProtocol = DocType.driverLicense
        let reservePhotoService: DocumentsReservePhotoServiceProtocol = DocumentsReservePhotoServiceImpl()
        let sharingApiClient: SharingDocsApiClientProtocol = SharingDocsAPIClient()
        let ratingServiceOpener: RateServiceProtocol = RatingServiceOpenerImpl()
        let faqOpener: FaqOpenerProtocol = FaqOpenerImpl()
        let replacementModule: CreateModuleCallback? = { DriverReplacementModule() }
        let docReorderingModule: CreateModuleCallback = { DocumentsReorderingModule() }
        let docStackReorderingModule: CreateModuleCallback = { DocumentsStackReorderingModule(docType: .driverLicense) }
        let storeHelper: DriverLicenseDocumentStorage = DriverLicenseDocumentStorageImpl(storage: StoreHelper.instance)
        let urlHandler: URLOpenerProtocol = URLOpenerImpl()
        
        let context = DriverLicenseContext(model: model,
                                           docType: docType,
                                           reservePhotoService: reservePhotoService,
                                           sharingApiClient: sharingApiClient,
                                           ratingOpener: ratingServiceOpener,
                                           faqOpener: faqOpener,
                                           replacementModule: replacementModule,
                                           docReorderingModule: docReorderingModule,
                                           docStackReorderingModule: docStackReorderingModule,
                                           storeHelper: storeHelper,
                                           urlHandler: urlHandler)
        
        return DriverLicenseViewModel(context: context)
    }
}
```

Usage of the `DriverLicenseViewModel` for processing `DocumentModel` after retrieving its data model from storage in the `DocumentsProcessor`

```swift
import DiiaMVPModule
import DiiaDocumentsCommonTypes
import DiiaDocumentsCore
import DiiaDocuments

final class DocumentsProcessor: DocumentsProcessorProtocol {
    // ...
    func documents(with order: [DocTypeCode], actionView: BaseView?) -> [MultiDataType<DocumentModel>] {
        
        let docTypesOrder: [DocType] = order.compactMap({ DocType(rawValue: $0)})
        
        let documents = docTypesOrder.compactMap { docType -> MultiDataType<DocumentModel>? in
            switch docType {
            case .driverLicense:
                let driverLicense: DSFullDocumentModel? = storeHelper.getValue(forKey: .driverLicense)
                return makeMultiple(cards: processDriverLicenses(licenses: driverLicense))
            }
        }
        
        return documents
    }
    // ...
    private func processDriverLicenses(licenses: DSFullDocumentModel?) -> [DocumentModel] {
        let documents: [DocumentModel] = licenses?.data.filter({ $0.docData.validUntil == nil }).map {
            return DriverLicenseViewModelFactory().createViewModel(model: $0)
        } ?? []
        return reorderIfNeeded(documents: documents, orderIds: DocumentReorderingService.shared.order(for: DocType.driverLicense.rawValue))
    }
    // ...
}
```

## Adding a new document module to the DiiaDocuments package

Adding a new Document to DiiaDocuments involves several steps to ensure proper integration and functionality. 
Here is the guideline:

1. _Project Structure:_
Create a new directory in `Sources/Documents` for your do document module. For example, if your functionality is called `SomeDocument`, create a directory like `Sources/Documents/SomeDocument`.

2. _Swift Files:_
Add the Swift files for your document module to the newly created directory. These files should contain the implementation of your document, including document-specific classes, structures, functions, or protocols.

3. _Dependencies:_
If the document module depends on external dependencies, list them in the Package.swift file under the dependencies section for `DiiaDocuments` target.
Use the Swift Package Manager (SPM) to manage dependencies.

4. _Public Interfaces:_
Define which entities (classes, structures, functions, etc.) from your document module should be accessible outside the module. 
Declare them as available in their respective Swift files. 
Define an `entry point viewModel` to which you will pass the `context` with the required dependencies for service-wide injection.

5. _Documentation:_
Write documentation for your document module using comments if possible. Clear and concise documentation makes it easier for users to understand and integrate your module. 
Update the README.md file with information about the new document.

6. _Integration and Usage:_
Integrate the updated Swift package into projects that require the new document module as described in the `Installation` section above. Use the Swift Package Manager to make sure everything compiles and works properly.
Use the `SomeDocumentViewModel` entry point with the context for the `processSomeDocumenentCard` method in the `DocumentsProcessor`, which should be used to retrieve the document data model from the storage.

## Code Verification

### Testing

In order to run tests and check coverage please follow next steps
We use [xcov](https://github.com/fastlane-community/xcov) in order to run
This guidline provides step-by-step instructions on running xcove locally through a shell script. Discover the process and locate the results conveniently in .html format.

1. Install [xcov](https://github.com/fastlane-community/xcov)
2. go to folder ./Scripts then run `sh xcove_runner.sh`
3. In order to check coverage report find the file `index.html` in the folder `../../xcove_output`.

We use `Scripts/.xcovignore` xcov configuration file in order to exclude files that are not going to be covered by unit tests (views, models and so on) from coverage result.


### Swiftlint

It is used [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions. The app should build and work without it, but if you plan to write code, you are encouraged to install SwiftLint.

You can run SwiftLint manully by running 
```bash
swiftlint Sources --quiet --reporter html > Scripts/swiftlint_report.html.
```
You can also set up a Git [pre-commit hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) to run SwiftLint automatically by copy Scripts/githooks into .git/hooks

## How to contribute

The Diia project welcomes contributions into this solution; please refer to the [CONTRIBUTING.md](./CONTRIBUTING.md) file for details

## Licensing

Copyright (C) Diia and all other contributors.

Licensed under the  **EUPL**  (the "License"); you may not use this file except in compliance with the License. Re-use is permitted, although not encouraged, under the EUPL, with the exception of source files that contain a different license.

You may obtain a copy of the License at  [https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12](https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12).

Questions regarding the Diia project, the License and any re-use should be directed to [modt.opensource@thedigital.gov.ua](mailto:modt.opensource@thedigital.gov.ua).
