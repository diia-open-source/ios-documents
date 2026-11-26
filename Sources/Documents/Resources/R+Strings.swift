
import Foundation

internal extension R {
    enum Strings: String, CaseIterable {
        
        // MARK: - General
        case general_translate_ukrainian
        case general_translate_english

        // MARK: - Passport Booklet
        case booklet_title
        case booklet_flag
        case booklet_photo
        case booklet_no_photo
        case booklet_signature
        case booklet_last_name
        case booklet_first_name
        case booklet_middle_name
        case booklet_birth_date
        case booklet_birth_place
        case booklet_sex
        case booklet_issued_at
        case booklet_issued_by
        case booklet_valid_until

        // MARK: - DriverLicense
        case driver_error_photo
        case driver_error_photo_descr
        case driver_error_need_verification
        case driver_error_need_verification_descr
        case driver_error_need_verification_descr_mvs
        case driver_error_old_format
        case driver_error_old_format_descr
        case driver_error_action
        case driver_error_to_driver_action
        case driver_error_to_driver_search_action
        case driver_error_destroyed
        case driver_error_destroyed_description
        case driver_error_destroyed_action
        case driver_error_transferred_to_storage_title
        case driver_error_transferred_to_storage_description
        case driver_error_deposited_title
        case driver_error_deposited_description
        case driver_error_photo_en
        case driver_error_photo_descr_en
        case driver_error_need_verification_en
        case driver_error_need_verification_descr_en
        case driver_error_old_format_en
        case driver_error_old_format_descr_en
        case driver_error_action_en
        case driver_error_to_driver_action_en
        
        // MARK: - Action Titles
        case action_title_full_info
        
        // MARK: - DriverLicense Replacement
        case driver_license_replacement

        // MARK: - DocumentsGeneral
        case document_general_change_documents_order
        case document_general_rate
        case document_general_change_stack_documents_order

        // MARK: - Menu
        case menu_faq
        
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
