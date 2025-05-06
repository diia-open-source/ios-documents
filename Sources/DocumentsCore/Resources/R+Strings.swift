import Foundation

internal extension R {
    enum Strings: String, CaseIterable {
    
        // MARK: - DocumentsGeneral
        case document_general_change_documents_order
        case document_general_reachability_error
        case document_general_add_document
        case general_accessibility_close
        case document_general_error_codes_not_loaded
        case document_general_error_codes_not_loaded_en
        
        // MARK: - Accessibility
        case documents_collection_accessibility_page_control
        case documents_collection_accessibility_page_control_hint
        case documents_collection_accessibility_reachability_error
        case documents_card_stack_accessibility_label

        case document_general_retry
        case document_general_retry_en
        
        // MARK: - Errors
        
        func localized() -> String {
            let localized = NSLocalizedString(rawValue, bundle: Bundle.module, comment: "")
            return localized
        }
        
        func formattedLocalized(arguments: CVarArg...) -> String {
            let localized = NSLocalizedString(rawValue, bundle: Bundle.module, comment: "")
            return String(format: localized, arguments)
        }
    }
}
