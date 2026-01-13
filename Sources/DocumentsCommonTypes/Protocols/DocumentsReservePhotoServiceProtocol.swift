
import Foundation

public protocol DocumentsReservePhotoServiceProtocol {
    func findReservePassportPhoto() -> String?
    func findReserveSavedPhoto() -> String?
}
