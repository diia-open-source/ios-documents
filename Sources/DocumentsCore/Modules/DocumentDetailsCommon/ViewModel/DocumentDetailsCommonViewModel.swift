
import UIKit
import DiiaUIComponents
import DiiaDocumentsCommonTypes

public class DocumentDetailsCommonViewModel {
    
    // MARK: - Properties
    public var model: DSDocumentData?
    public var images = [DSDocumentContentData: UIImage]()
    public var eventHandler: DSConsructorEventHandler?
    
    // MARK: - Init
    public init(model: DSDocumentData?,
                images: [DSDocumentContentData: UIImage],
                eventHandler: DSConsructorEventHandler?) {
        self.model = model
        self.images = images
        self.eventHandler = eventHandler
    }
}
