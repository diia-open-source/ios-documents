
import UIKit

internal enum R {
    enum Image: String, CaseIterable {
        case barcodeActive
        case barcodeInactive
        case qrCodeActive
        case qrCodeInactive
        case ds_stack
        case ds_stackWhite
        
        var image: UIImage? {
            return UIImage(named: rawValue, in: Bundle.module, compatibleWith: nil)
        }
        
        var name: String {
            return rawValue
        }
    }
}
