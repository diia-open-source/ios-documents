
import Foundation

public struct ShareLinkModel: Decodable {
    public let id: String
    public let link: String
    public let timerText: String?
    public let timerTime: Int?
    public let barcode: String?
}

public extension ShareLinkModel {
    init(id: String,
         link: String,
         barcode: String?,
         timerText: String = "",
         timerTime: Int = 0) {
        self.id = id
        self.link = link
        self.barcode = barcode
        self.timerText = timerText
        self.timerTime = timerTime
    }
}
