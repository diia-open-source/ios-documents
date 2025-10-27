import UIKit

public enum DocumentStackIconAppearance {
    case white
    case black
    
    public var color: UIColor {
        switch self {
        case .white:
            return .white
        case .black:
            return .black
        }
    }
    
    public var image: UIImage? {
        switch self {
        case .white:
            return R.Image.ds_stackWhite.image
        case .black:
            return R.Image.ds_stack.image
        }
    }
}
