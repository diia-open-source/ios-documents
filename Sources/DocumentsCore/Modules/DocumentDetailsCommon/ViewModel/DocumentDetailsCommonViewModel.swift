
import UIKit
import DiiaUIComponents
import DiiaDocumentsCommonTypes
import DiiaCommonTypes

public class DocumentDetailsCommonViewModel {
    
    // MARK: - Properties
    public var model: DSDocumentData?
    public var additionalInfoId: String?
    public var images = [DSDocumentContentData: UIImage]()
    public var eventHandler: DSConstructorEventHandler?
    
    // MARK: - Init
    public init(model: DSDocumentData?,
                additionalInfoId: String? = nil,
                images: [DSDocumentContentData: UIImage],
                eventHandler: DSConstructorEventHandler?) {
        self.model = model
        self.additionalInfoId = additionalInfoId
        self.images = images
        self.eventHandler = eventHandler
    }

    // MARK: - Public
    func bodyModel(for key: String?) -> [AnyCodable] {
        if let key {
            return model?.additionalFullInfo?.first(where: { $0.id == key })?.fullInfo ?? []
        } else {
            return model?.fullInfo ?? []
        }
    }
}
