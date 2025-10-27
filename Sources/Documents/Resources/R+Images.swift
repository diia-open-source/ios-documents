import UIKit

internal enum R {
    enum Image: String, CaseIterable {
        // MARK: - General
        case translate_english
        case translate_ukrainian
        
        // MARK: - Design System
        case ds_docInfo = "DS_docInfo"
        case ds_rating = "DS_rating"
        case ds_refresh = "DS_refresh"
        case ds_faq = "DS_faq"
        case ds_reorder = "DS_reorder"
        
        var image: UIImage? {
            return UIImage(named: rawValue, in: Bundle.module, compatibleWith: nil)
        }
        
        var name: String {
            return rawValue
        }
    }
}
