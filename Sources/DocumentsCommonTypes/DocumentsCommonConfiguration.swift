
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
