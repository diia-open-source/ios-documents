import Foundation
import DiiaCommonTypes
import DiiaUIComponents

public extension DriverLicenseStatus {

    func generateErrorViewModel(urlHandlerType: URLOpenerProtocol) -> DocumentErrorViewModel? {
        switch self {
        case .noPhoto:
            return DocumentErrorViewModel(
                title: R.Strings.driver_error_photo.localized(),
                description: R.Strings.driver_error_photo_descr.localized(),
                action: Action(title: R.Strings.driver_error_action.localized(),
                               iconName: nil,
                               callback: {
                                   _ = urlHandlerType.url(urlString: PackageConstants.URLs.mvsDriverQueueUrl, linkType: nil)
            }))
        case .needVerification:
            return DocumentErrorViewModel(
                title: R.Strings.driver_error_need_verification.localized(),
                description: R.Strings.driver_error_need_verification_descr_mvs.localized(),
                action: Action(title: R.Strings.driver_error_to_driver_search_action.localized(),
                               iconName: nil,
                               callback: {
                                   _ = urlHandlerType.url(urlString: PackageConstants.URLs.mvsMainServiceCenterUrl, linkType: nil)
            }))
        case .oldFormat:
            return DocumentErrorViewModel(
                title: R.Strings.driver_error_old_format.localized(),
                description: R.Strings.driver_error_old_format_descr.localized(),
                action: Action(title: R.Strings.driver_error_action.localized(),
                               iconName: nil,
                               callback: {
                                   _ = urlHandlerType.url(urlString: PackageConstants.URLs.mvsDriverQueueUrl, linkType: nil)
            }))
        default:
            return nil
        }
    }

    func generateErrorViewModelEn(urlHandlerType: URLOpenerProtocol) -> DocumentErrorViewModel? {
        switch self {
        case .noPhoto:
            return DocumentErrorViewModel(
                title: R.Strings.driver_error_photo_en.localized(),
                description: R.Strings.driver_error_photo_descr_en.localized(),
                action: Action(title: R.Strings.driver_error_action_en.localized(),
                               iconName: nil,
                               callback: {
                                   _ = urlHandlerType.url(urlString: PackageConstants.URLs.mvsDriverQueueUrl, linkType: nil)
            }))
        case .needVerification:
            return DocumentErrorViewModel(
                title: R.Strings.driver_error_need_verification_en.localized(),
                description: R.Strings.driver_error_need_verification_descr_en.localized(),
                action: Action(title: R.Strings.driver_error_to_driver_action_en.localized(),
                               iconName: nil,
                               callback: {
                                   _ = urlHandlerType.url(urlString: PackageConstants.URLs.mvsDriverQueueUrl, linkType: nil)
            }))
        case .oldFormat:
            return DocumentErrorViewModel(
                title: R.Strings.driver_error_old_format_en.localized(),
                description: R.Strings.driver_error_old_format_descr_en.localized(),
                action: Action(title: R.Strings.driver_error_action_en.localized(),
                               iconName: nil,
                               callback: {
                                   _ = urlHandlerType.url(urlString: PackageConstants.URLs.mvsDriverQueueUrl, linkType: nil)
            }))
        default:
            return nil
        }
    }
}
