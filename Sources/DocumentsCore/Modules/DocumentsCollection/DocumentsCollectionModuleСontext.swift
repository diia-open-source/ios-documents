import Foundation
import Alamofire
import ReactiveKit
import DiiaCommonTypes
import DiiaUIComponents
import DiiaDocumentsCommonTypes

public struct DocumentsCoreNetworkContext {
    public let session: Alamofire.Session
    public let host: String
    public let headers: [String: String]?

    public init(session: Alamofire.Session, host: String, headers: [String: String]?) {
        self.session = session
        self.host = host
        self.headers = headers
    }
}

public struct DocumentsReorderingConfiguration {
    let createReorderingModule: CreateModuleCallback
    let reorderingService: DocumentReorderingServiceProtocol
    
    public init(createReorderingModule: @escaping CreateModuleCallback, documentsReorderingService: DocumentReorderingServiceProtocol) {
        self.createReorderingModule = createReorderingModule
        self.reorderingService = documentsReorderingService
    }
}

public struct DocumentsCollectionModuleСontext {
    let network: DocumentsCoreNetworkContext
    let documentsLoader: DocumentsLoaderProtocol
    let docProvider: DocumentsProvider
    let documentsStackRouterCreate: (DocumentAttributesProtocol) -> RouterProtocol
    let documentsReorderingConfiguration: DocumentsReorderingConfiguration
    let pushNotificationsSharingSubject: PassthroughSubject<Void, Never>
    let addDocumentsActionProvider: AddDocumentsActionProviderProtocol

    public init(network: DocumentsCoreNetworkContext,
                documentsLoader: DocumentsLoaderProtocol,
                docProvider: DocumentsProvider,
                documentsStackRouterCreate: @escaping (DocumentAttributesProtocol) -> RouterProtocol,
                actionFabricAllowedCodes: [DocTypeCode],
                documentsReorderingConfiguration: DocumentsReorderingConfiguration,
                pushNotificationsSharingSubject: PassthroughSubject<Void, Never>,
                addDocumentsActionProvider: AddDocumentsActionProviderProtocol,
                imageNameProvider: DSImageNameProvider,
                screenBrightnessService: ScreenBrightnessServiceProtocol) {
        self.network = network
        self.documentsLoader = documentsLoader
        self.docProvider = docProvider
        self.documentsStackRouterCreate = documentsStackRouterCreate
        self.documentsReorderingConfiguration = documentsReorderingConfiguration
        self.pushNotificationsSharingSubject = pushNotificationsSharingSubject
        self.addDocumentsActionProvider = addDocumentsActionProvider
        
        AppConstants.actionFabricAllowedCodes = actionFabricAllowedCodes

        // configuring linked modules
        DocumentsCommonConfiguration.shared.setup(imageNameProvider: imageNameProvider, screenBrightnessService: screenBrightnessService)
    }
}
