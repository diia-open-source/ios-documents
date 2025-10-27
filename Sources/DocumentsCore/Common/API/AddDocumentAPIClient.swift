import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaDocumentsCommonTypes

protocol AddDocumentAPIClientProtocol {
    func getDocsToAdd() -> Signal<AllDocsToAdd, NetworkError>
}

class AddDocumentAPIClient: ApiClient<AddDocumentAPI>, AddDocumentAPIClientProtocol {
    public init(context: DocumentsCoreNetworkContext) {
        super.init()
        sessionManager = context.session
        AddDocumentAPI.host = context.host
        AddDocumentAPI.headers = context.headers
    }

    func getDocsToAdd() -> Signal<AllDocsToAdd, NetworkError> {
        return request(.getDocsToAdd)
    }
}
