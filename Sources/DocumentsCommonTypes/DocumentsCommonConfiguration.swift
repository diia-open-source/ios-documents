
import Foundation
import DiiaCommonTypes
import DiiaUIComponents

public final class DocumentsCommonConfiguration {
    public static let shared = DocumentsCommonConfiguration()
    
    public var imageProvider: DSImageNameProvider?
    public var screenBrightnessService: ScreenBrightnessServiceProtocol?
    
    ///   - imageNameProvider: The image provider for DS components . Can be `nil` if not applicable.
    ///   - screenBrightnessService: A service responsible for managing screen brightness.
    public func setup(imageNameProvider: DSImageNameProvider, screenBrightnessService: ScreenBrightnessServiceProtocol) {
        self.imageProvider = imageNameProvider
        self.screenBrightnessService = screenBrightnessService
    }
}

import UIKit

public final class DocumentImageResolver: DSImageNameProvider {
    private let imagesContent: [DSDocumentContentData: UIImage]
    
    public init(imagesContent: [DSDocumentContentData: UIImage]) {
        self.imagesContent = imagesContent
    }
    
    public func imageForCode(imageCode: String, placeholder: UIImage?) -> UIImage? {
        guard let image = imageForCode(imageCode: imageCode) else { return placeholder }
        return image
    }
    
    public func imageForCode(imageCode: String?) -> UIImage? {
        guard let imageCode, let key = DSDocumentContentData(rawValue: imageCode) else { return nil }
        
        return imagesContent[key]
    }
    
    public func imageNameForCode(imageCode: String) -> String {
        return imageCode
    }
}
