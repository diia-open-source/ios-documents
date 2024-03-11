import Foundation
import DiiaCommonTypes
import DiiaMVPModule
import DiiaDocumentsCommonTypes

protocol DocumentActionsFabricProtocol {
    func getAction(
        for dataType: MultiDataType<DocumentModel>,
        view: BaseView,
        flipper: FlipperVerifyProtocol
    ) -> Callback?
}

struct DocumentActionsFabric: DocumentActionsFabricProtocol {
    
    private let allowedDocTypeCodes: [DocTypeCode]

    init() {
        self.allowedDocTypeCodes = AppConstants.actionFabricAllowedCodes
    }
    
    func getAction(
        for dataType: MultiDataType<DocumentModel>,
        view: BaseView,
        flipper: FlipperVerifyProtocol
    ) -> Callback? {
        let actions: [[Action]]

        switch dataType {
        case .single(let document):
            actions = document.getCardActions(view: view, flipper: flipper)
        case .multiple:
            return nil
        }
        
        if actions.isEmpty {
            return nil
        }
        let dataTypeValue = dataType.getValue()
        return { [weak view, weak dataTypeValue, weak flipper] in
            guard let flipper = flipper else { return }
            view?.showChild(module: DocumentActionSheetModule(actions: actions,
                                                              codeAction: self.getCodeAction(docType: dataTypeValue?.docType?.docCode,
                                                                                             flipper: flipper)))

        }
    }
    
    // MARK: - Private
    private func getCodeAction(docType: DocTypeCode?, flipper: FlipperVerifyProtocol) -> ((VerificationType) -> Void)? {
        guard let docType = docType else { return nil }
        let isAllowed = allowedDocTypeCodes.contains(docType)
        
        return isAllowed ? { [weak flipper] verificationType in flipper?.flip(for: verificationType) } : nil
    }
}
