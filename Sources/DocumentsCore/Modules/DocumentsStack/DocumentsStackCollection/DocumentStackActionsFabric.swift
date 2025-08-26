
import Foundation
import DiiaMVPModule
import DiiaCommonTypes
import DiiaDocumentsCommonTypes

struct DocumentStackActionsFabric: DocumentActionsFabricProtocol {
    
    private let allowedDocTypeCodes: [DocTypeCode]

    init() {
        self.allowedDocTypeCodes = AppConstants.actionFabricAllowedCodes
    }
    
    func getAction(
        for dataType: MultiDataType<DocumentModel>,
        view: BaseView,
        flipper: FlipperVerifyProtocol
    ) -> Callback? {
        var actions: [[Action]] = []

        switch dataType {
        case .single(let document):
            actions = document.getInstackCardActions(view: view, flipper: flipper)
        case .multiple:
            break
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
    
    func getAccessibilityMenuActions(
        for dataType: MultiDataType<DocumentModel>,
        view: BaseView,
        flipper: FlipperVerifyProtocol,
        openStackDocument: Callback?
    ) -> Callback? {
        let actions: [[Action]]
        
        switch dataType {
        case .single(let document):
            actions = document.getAccessibilityMenuAction(view: view, flipper: flipper, inStack: true)
        case .multiple:
            guard let openStackDocument else { return nil }
            actions = [[Action(title: R.Strings.document_open_in_stack_accessibility.localized(), image: nil, callback: openStackDocument)]]
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
