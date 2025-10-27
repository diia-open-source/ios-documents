import UIKit

internal enum R {
    enum Image: String, CaseIterable {
        case backCardSkeleton
        case imagePlusBlack
        case changeOrder
        case menu_back
        case ds_stack
        
        var image: UIImage? {
            return UIImage(named: rawValue, in: Bundle.module, compatibleWith: nil)
        }
        
        var name: String {
            return rawValue
        }
    }
}
