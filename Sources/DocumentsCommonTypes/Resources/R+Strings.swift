import Foundation

internal extension R {
    enum Strings: String, CaseIterable {
    
        // MARK: - General
        case general_qr_code
        case general_barcode
        case general_update_code_action
        case general_update_code_action_en
        case document_general_qr_code_en
        case document_general_barcode_en
        case document_general_qr_session_time
        case document_general_retry
        case document_general_retry_en
        case document_general_session_time
        case document_general_registry_error
        case document_general_registry_error_en
        case document_general_registry_error_description
        case document_general_registry_error_description_en
        case error_code_expired
        case error_code_expired_en
        
        // MARK: - Accessibility
        case documents_collection_accessibility_verification_view_content
        case documents_collection_accessibility_verification_view_offline
        case documents_collection_accessibility_verification_view
        case documents_collection_accessibility_verification_view_hint
        case document_general_error_codes_not_loaded
        case document_general_error_codes_not_loaded_en

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
